! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.com/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_tracer_meke
!
!> \brief MPAS ocean Mesoscale EKE source and sink terms
!> \author Carolyn Begeman
!> \date   07/11/2022
!> \version 
!> \details
!>  This module contains the routines for computing MEKE tendencies
!>  due to source and sink terms
!
!-----------------------------------------------------------------------

module ocn_tracer_meke_tend

   use mpas_timer
   use mpas_derived_types
   use mpas_pool_routines
   use ocn_constants
   use ocn_config
   use ocn_diagnostics_variables
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

   public :: ocn_tracer_meke_source_tend, &
             ocn_tracer_meke_tend_init

   !--------------------------------------------------------------------
   !
   ! Private module variables
   !
   !--------------------------------------------------------------------


!***********************************************************************

contains

!***********************************************************************
!
!  routine ocn_tracer_meke_source_tend
!
!> \brief   Computes MEKE source terms
!> \author  Carolyn Begeman
!> \date    07/11/2022
!> \details
!>  This routine computes the tendency for MEKE due to baroclinic 
!>  instability source
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_meke_source_tend(dt, tend, err)!{{{
      !-----------------------------------------------------------------
      !
      ! input variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), intent(in) :: dt ! time step

      !-----------------------------------------------------------------
      !
      ! input/output variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:), intent(inout) :: &
         tend          !< Input/Output: MEKE tendency

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

      integer :: iCell, iEdge, k, nCells, nEdges
      real (kind=RKIND), dimension(:,:), allocatable :: &
         mekeSource, &
         mekeSourceEdge

      call mpas_log_write('MEKE source start')
      err = 0

      if (.not. config_prognostic_meke) return

      call mpas_timer_start('MEKE source')

      nCells = nCellsOwned
      nEdges = nEdgesAll

      allocate(mekeSource(nVertLevels, nCells))
      allocate(mekeSourceEdge(nVertLevels+1, nEdges))

      ! mekeSourceTopOfEdge comes from diagnostics_variables
      ! first, interpolate mekeSourceTopOfEdge to mekeSourceEdge
      call mpas_log_write('Interpolate meke source to mid-edge')
      !$omp parallel
      !$omp do schedule(runtime) private(k)
      do iEdge = 1, nEdges
        mekeSourceEdge(:, iEdge) = 0.0_RKIND
        do k = minLevelEdgeTop(iEdge), maxLevelEdgeBot(iEdge)
          mekeSourceEdge(k, iEdge) = 0.5_RKIND *  &
                                     (mekeSourceTopOfEdge(k, iEdge) + &
                                      mekeSourceTopOfEdge(k+1, iEdge))
        end do
      end do
      !$omp end do
      !$omp end parallel
      call mpas_log_write('... completed')

      ! second, interpolate mekeSourceEdge to cell centers
      call mpas_log_write('Interpolate meke source to cell center')
      !$omp parallel
      !$omp do schedule(runtime) private(k)
      do iCell = 1, nCells
        mekeSource(:, iCell) = 0.0_RKIND
        do iEdge = 1, nEdgesOnCell(iCell)
          do k = minLevelEdgeBot(iEdge), maxLevelEdgeTop(iEdge)
            mekeSource(k, iCell) = mekeSource(k, iCell) + &
               mekeSourceEdge(k, iEdge) * edgeAreaFractionOfCell(iEdge, iCell)
          end do
        end do
      end do
      !$omp end do
      !$omp end parallel
      call mpas_log_write('... completed')

      call mpas_log_write('Compute meke source tend')
      !$omp parallel
      !$omp do schedule(runtime) private(k)
      do iCell = 1, nCells
        do k = minLevelCell(iCell), maxLevelCell(iCell)

          tend(k, iCell) = tend(k, iCell) + dt * mekeSource(k, iCell)
        end do
      end do
      !$omp end do
      !$omp end parallel
      call mpas_log_write('... completed')

      call mpas_timer_stop('MEKE source')

   !--------------------------------------------------------------------

   end subroutine ocn_tracer_meke_source_tend!}}}

!***********************************************************************
!
!  routine ocn_tracer_meke_tend_init
!
!> \brief   Initializes ocean MEKE tendency computation
!> \author  Carolyn Begeman
!> \date    07/11/2022
!> \version 
!> \details
!>  This routine initializes quantities related to MEKE tendency
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_meke_tend_init(err)!{{{

   !--------------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      err = 0

   end subroutine ocn_tracer_meke_tend_init!}}}

!***********************************************************************

end module ocn_tracer_meke_tend

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
! vim: foldmethod=marker
