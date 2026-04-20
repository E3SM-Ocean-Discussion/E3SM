! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.io/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_tracer_nonlocalflux
!
!> \brief MPAS ocean tracer non-local flux
!> \author Todd Ringler
!> \date   11/25/13
!> \version SVN:$Id:$
!> \details
!>  This module contains the routine for computing
!>  tracer tendencies due to non-local vertical fluxes computed in CVMix KPP
!
!-----------------------------------------------------------------------

module ocn_tracer_nonlocalflux

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

   public :: ocn_tracer_nonlocalflux_tend, &
             ocn_tracer_nonlocalflux_init, &
             ocn_brine_rejection_tendency

   !--------------------------------------------------------------------
   !
   ! Private module variables
   !
   !--------------------------------------------------------------------

   logical :: nonLocalFluxOn

!***********************************************************************

contains

!***********************************************************************
!
!  routine ocn_brine_rejction_tend
!
!> \brief   Computes tendency term due to brine rejection
!> \author  Luke Van Roekel
!> \date    11/08/24
!> \details
!>  This routine computes the tendency for salinity from brine rejection, based on 
!>      Nguyen et al 2009
!
!-----------------------------------------------------------------------

   subroutine ocn_brine_rejection_tendency(tend, layerThickness, seaIceSalinityFlux, index_salinity, dt, err)
      !----------------------------------------------------------------
      !
      ! variables
      !
      !----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:,:), intent(inout) :: &
         tend !< tracer tendency, only will modify the salinity tend here

      real (kind=RKIND), dimension(:), intent(in) :: &
         seaIceSalinityFlux

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         layerThickness

      real, dimension(:), allocatable :: sis_flux

      real (kind=RKIND) :: dt

      integer, intent(in) :: index_salinity

      integer :: err

      !----------------------------------------------------------------
      !
      ! local variables
      !
      !----------------------------------------------------------------

      integer :: iCell, k, nCells

      real (kind=RKIND) :: remainder, z, integral, D, A, rejectedSalt

      nCells = nCellsHalo(1)

      allocate(sis_flux(nVertLevels+1))

      do iCell = 1, nCells
        if (seaIceSalinityFlux(iCell) > 0) then !only compute for salinity into ocean
           !this is set to 1 such that across the BLD we don't have a huge salt flux divergence.
           sis_flux(:) = 1.0_RKIND*seaIceSalinityFlux(iCell)
           D = boundaryLayerDepth(iCell)
           z = 0.0_RKIND
           A = (config_brine_param_n + 1) / D**(config_brine_param_n+1)
           k = minLevelCell(iCell)
           ! need a salinity flux top and bottom and the flux into a cell is the divergence??
           do while (z < D)
              sis_flux(k) = min(1.0_RKIND,A*z**config_brine_param_n)*seaIceSalinityFlux(iCell)
              z = z + layerThickness(k,iCell)
              k = k + 1
           end do
           ! need to pick up the last bit that goes over
           sis_flux(k) = 1.0_RKIND*seaIceSalinityFlux(iCell) ! this should finish
          
           do k=minLevelCell(iCell),maxLevelCell(iCell)
              ! need to flip over so we take k+1 - k
              tend(index_salinity, k, iCell) = tend(index_salinity, k, iCell) + &
                 sis_flux(k+1) - sis_flux(k)
           end do
        end if
      end do

      deallocate(sis_flux)
  end subroutine ocn_brine_rejection_tendency

!***********************************************************************
!
!  routine ocn_tracer_nonlocalflux_tend
!
!> \brief   Computes tendency term due to non-local flux transport
!> \author  Todd Ringler
!> \date    11/25/13
!> \details
!>  This routine computes the tendency for tracers based the vertical divergence of non-local fluxes.
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_nonlocalflux_tend(vertNonLocalFlux, surfaceTracerFlux, tend, err)!{{{
      !-----------------------------------------------------------------
      !
      ! input variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:), intent(in) :: &
        surfaceTracerFlux !< Input: surface tracer fluxes

      real (kind=RKIND), dimension(:,:,:), intent(in) :: &
        vertNonLocalFlux !< Input: non-local flux of tracers defined at layer interfaces

      !-----------------------------------------------------------------
      !
      ! input/output variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:,:), intent(inout) :: &
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

      integer :: iCell, k, iTracer, nTracers, nCells
      real (kind=RKIND) :: fluxTopOfCell, fluxBottomOfCell

      err = 0

      if (.not. nonLocalFluxOn) return

      call mpas_timer_start('non-local flux')

      nTracers = size(tend, dim=1)

      nCells = nCellsHalo( 1 )

      !$omp parallel
      !$omp do schedule(runtime) private(k, iTracer, fluxTopOfCell, fluxBottomOfCell)
      do iCell = 1, nCells
        do k = minLevelCell(iCell)+1, maxLevelCell(iCell)-1

          ! NOTE: at the moment, all tracers are based on the flux-profile used for temperature, i.e. vertNonLocalFlux(1,:,:)
          do iTracer = 1, nTracers
            fluxTopOfCell = surfaceTracerFlux(iTracer, iCell) * vertNonLocalFlux(1, k, iCell)
            fluxBottomOfCell = surfaceTracerFlux(iTracer, iCell) * vertNonLocalFlux(1, k+1, iCell)
            tend(iTracer, k, iCell) = tend(iTracer, k, iCell) + (fluxTopOfCell-fluxBottomOfCell)
          end do
        end do

        ! enforce boundary conditions at bottom of column
        k = maxLevelCell(iCell)
        do iTracer = 1, nTracers
          fluxTopOfCell = surfaceTracerFlux(iTracer, iCell) * vertNonLocalFlux(1, k, iCell)
          fluxBottomOfCell = 0.0_RKIND
          tend(iTracer, k, iCell) = tend(iTracer, k, iCell) + (fluxTopOfCell-fluxBottomOfCell)
        end do

        ! enforce boundary conditions at top of column
        k = minLevelCell(iCell)
        do iTracer = 1, nTracers
          fluxTopOfCell = 0.0_RKIND
          fluxBottomOfCell = surfaceTracerFlux(iTracer, iCell) * vertNonLocalFlux(1, k+1, iCell)
          tend(iTracer, k, iCell) = tend(iTracer, k, iCell) + (fluxTopOfCell-fluxBottomOfCell)
        end do

      end do
      !$omp end do
      !$omp end parallel

      call mpas_timer_stop('non-local flux')

   !--------------------------------------------------------------------

   end subroutine ocn_tracer_nonlocalflux_tend!}}}

!***********************************************************************
!
!  routine ocn_tracer_nonlocalflux_init
!
!> \brief   Initializes ocean tracer nonlocal flux computation
!> \author  Todd Ringler
!> \date    11/25/13
!> \version SVN:$Id$
!> \details
!>  This routine initializes quantities related to nonlocal flux computation
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_nonlocalflux_init(err)!{{{

   !--------------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      err = 0

      nonLocalFluxOn = .true.

      if (config_disable_tr_nonlocalflux) then
         nonLocalFluxOn = .false.
      end if

      if (.not.config_use_cvmix_kpp) then
         nonLocalFluxOn = .false.
      end if

   end subroutine ocn_tracer_nonlocalflux_init!}}}

!***********************************************************************

end module ocn_tracer_nonlocalflux

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
! vim: foldmethod=marker
