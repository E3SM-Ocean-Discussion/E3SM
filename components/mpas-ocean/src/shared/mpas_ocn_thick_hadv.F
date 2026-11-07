! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.io/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_thick_hadv
!
!> \brief MPAS ocean horizontal advection for thickness
!> \author Doug Jacobsen
!> \date   16 September 2011
!> \details
!>  This module contains the routine for computing
!>  tendencies for thickness from horizontal advection
!
!-----------------------------------------------------------------------

module ocn_thick_hadv

   use mpas_timer
   use mpas_derived_types
   use mpas_pool_routines
   use ocn_constants
   use ocn_config
   use ocn_mesh

   implicit none
   private
   save

   !--------------------------------------------------------------------
   !
   ! Public parameters
   !
   !--------------------------------------------------------------------

   !--------------------------------------------------------------------
   !
   ! Public member functions
   !
   !--------------------------------------------------------------------

   public :: ocn_thick_hadv_tend, &
             ocn_thick_hadv_flux, &
             ocn_thick_hadv_init

   !--------------------------------------------------------------------
   !
   ! Private module variables
   !
   !--------------------------------------------------------------------

   logical :: thickHadvOn

!***********************************************************************

contains

!***********************************************************************
!
!  routine ocn_thick_hadv_tend
!
!> \brief   Computes tendency term from horizontal advection of thickness
!> \author  Doug Jacobsen
!> \date    15 September 2011
!> \details
!>  This routine computes the horizontal advection tendency for
!>  thicknes based on current state and user choices of forcings.
!
!-----------------------------------------------------------------------

   subroutine ocn_thick_hadv_tend(normalVelocity, layerThickEdgeFlux, tend, err)!{{{

      !-----------------------------------------------------------------
      !
      ! input variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         normalVelocity    !< Input: velocity

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         layerThickEdgeFlux     !< Input: flux-related thickness at edge

      !-----------------------------------------------------------------
      !
      ! input/output variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:), intent(inout) :: &
         tend          !< Input/Output: velocity tendency

      !-----------------------------------------------------------------
      !
      ! output variables
      !
      !-----------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      !-----------------------------------------------------------------
      !
      ! local variables
      !
      !-----------------------------------------------------------------

      integer :: iEdge, k, i, iCell

      real (kind=RKIND) :: flux, invAreaCell

      !-----------------------------------------------------------------
      !
      ! call relevant routines for computing tendencies
      ! note that the user can choose multiple options and the
      !   tendencies will be added together
      !
      !-----------------------------------------------------------------

      err = 0

      if(.not.thickHadvOn) return

      call mpas_timer_start("thick hadv")

#ifdef MPAS_OPENACC
      !$acc parallel loop &
      !$acc     present(tend, normalVelocity, dvEdge, &
      !$acc             layerThickEdgeFlux, edgeSignOnCell, &
      !$acc             minLevelEdgeBot, maxLevelEdgeBot) &
      !$acc     private(i, k, invAreaCell, flux)
#else
      !$omp parallel
      !$omp do schedule(runtime) private(invAreaCell, i, iEdge, k, flux)
#endif
      do iCell = 1, nCellsOwned
        invAreaCell = 1.0_RKIND / areaCell(iCell)
        do i = 1, nEdgesOnCell(iCell)
          iEdge = edgesOnCell(i, iCell)
          do k = minLevelEdgeBot(iEdge), maxLevelEdgeTop(iEdge)
            flux = normalVelocity(k, iEdge) * dvEdge(iEdge) * layerThickEdgeFlux(k, iEdge)
            tend(k, iCell) = tend(k, iCell) + edgeSignOnCell(i, iCell) * flux * invAreaCell
          end do
        end do
      end do
#ifndef MPAS_OPENACC
      !$omp end do
      !$omp end parallel
#endif

      call mpas_timer_stop("thick hadv")

   !--------------------------------------------------------------------

   end subroutine ocn_thick_hadv_tend!}}}

!***********************************************************************
!
!  routine ocn_thick_hadv_flux
!
!> \brief   Accumulates the thickness flux across edges
!> \details
!>  This routine adds weight times the per-layer thickness flux per unit
!>  edge length, normalVelocity*layerThickEdgeFlux, to flux on each owned
!>  edge, over the levels that ocn_thick_hadv_tend uses.  With reset, flux
!>  is set to zero first.  The time integrators call it with the velocity
!>  and edge thickness of their thickness update, so that flux holds the
!>  flux that update applies.
!
!-----------------------------------------------------------------------

   subroutine ocn_thick_hadv_flux(normalVelocity, layerThickEdgeFlux, &
                                  weight, reset, flux)!{{{

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         normalVelocity    !< Input: transport velocity

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         layerThickEdgeFlux     !< Input: flux-related thickness at edge

      real (kind=RKIND), intent(in) :: &
         weight       !< Input: weight of this flux in the accumulation

      logical, intent(in) :: &
         reset        !< Input: whether to zero flux first

      real (kind=RKIND), dimension(:,:), intent(inout) :: &
         flux         !< Input/Output: accumulated thickness flux

      integer :: iEdge, k

      !$omp parallel
      !$omp do schedule(runtime) private(k)
      do iEdge = 1, nEdgesOwned
         if (reset) flux(:, iEdge) = 0.0_RKIND
         do k = minLevelEdgeBot(iEdge), maxLevelEdgeTop(iEdge)
            flux(k, iEdge) = flux(k, iEdge) + weight * &
                             normalVelocity(k, iEdge) * layerThickEdgeFlux(k, iEdge)
         end do
      end do
      !$omp end do
      !$omp end parallel

   end subroutine ocn_thick_hadv_flux!}}}

!***********************************************************************
!
!  routine ocn_thick_hadv_init
!
!> \brief   Initializes ocean horizontal thickness advection
!> \author  Doug Jacobsen
!> \date    16 September 2011
!> \details
!>  This routine initializes quantities related to horizontal thickness
!>  advection in the ocean.
!
!-----------------------------------------------------------------------

   subroutine ocn_thick_hadv_init(err)!{{{

   !--------------------------------------------------------------------

      !-----------------------------------------------------------------
      !
      ! call individual init routines for each parameterization
      !
      !-----------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      thickHadvOn = .true.

      if(config_disable_thick_hadv) thickHadvOn = .false.

      err = 0

   !--------------------------------------------------------------------

   end subroutine ocn_thick_hadv_init!}}}

!***********************************************************************

end module ocn_thick_hadv

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

! vim: foldmethod=marker
