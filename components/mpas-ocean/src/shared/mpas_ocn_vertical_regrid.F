! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.io/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_vertical_regrid
!
!> \brief MPAS ocean vertical regridding
!> \author Carolyn Begeman, Darren Engwirda, Xylar Asay-Davis
!> \date   July 2021
!> \details
!>  This module contains the vertical regridding routine, used for
!>  vertical Lagrangian remapping.
!
!-----------------------------------------------------------------------

module ocn_vertical_regrid

   use mpas_derived_types
   use mpas_pool_routines
   use mpas_constants
   use mpas_dmpar
   use mpas_threading
   use mpas_vector_reconstruction
   use mpas_spline_interpolation
   use mpas_timer
   use mpas_log

   use ocn_constants
   use ocn_config
   use ocn_mesh
   use ocn_thick_ale

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

   public :: ocn_vert_regrid
   public :: ocn_vert_regrid_init

   contains

!***********************************************************************
!
!  routine ocn_vert_regrid
!
!> \brief   Regridding for vertical Lagrangian remapping
!> \author  Carolyn Begeman
!> \date    2021
!> \details
!>  This routine determines the layerThickness to remap to subject to
!>  constraints
!
!-----------------------------------------------------------------------

   subroutine ocn_vert_regrid(verticalMeshPool, layerThicknessLag, &
                              layerThicknessTarget, err, newHighFreqThickness)

      type (mpas_pool_type), intent(in) :: &
         verticalMeshPool  ! vertical mesh information

      real (kind=RKIND), dimension(:, :), intent(in) :: &
         layerThicknessLag ! layerThickness after the lagrangian step

      !  alters ALE thickness when freq-filtering
      real (kind=RKIND), dimension(:,:), intent(in), optional :: &
         newHighFreqThickness     !< [in] high frequency thickness

      real (kind=RKIND), dimension(:,:), intent(inout) :: &
         layerThicknessTarget ! adjusted target layerThickness for remapping

      integer, intent(out) :: err !< Output: Error flag

      integer :: iCell, k, kmin, kmax

      real (kind=RKIND), dimension(:), allocatable :: projectedSSH
      real (kind=RKIND) :: totalThicknessTarget

      err = 0

      allocate(projectedSSH(nCellsAll))

      !$omp parallel
      !$omp do schedule(runtime) private(k)
      do iCell = 1, nCellsAll
         projectedSSH(iCell) = -bottomDepth(iCell)
         do k = maxLevelCell(iCell), minLevelCell(iCell), -1
            projectedSSH(iCell) = projectedSSH(iCell) + layerThicknessLag(k,iCell)
         end do
      end do
      !$omp end do
      !$omp end parallel

      !
      ! Compute desired thickness at new time
      !
      if (present(newHighFreqThickness)) then
        call ocn_ALE_thickness(verticalMeshPool, projectedSSH, &
                               layerThicknessTarget, err, newHighFreqThickness)
      else
        call ocn_ALE_thickness(verticalMeshPool, projectedSSH, &
                               layerThicknessTarget, err)
      endif

      !!$omp parallel
      !!$omp do schedule(runtime) private(k,totalThicknessTarget)
      do iCell = 1, nCellsAll
         totalThicknessTarget = 0.0_RKIND
         do k = minLevelCell(iCell), maxLevelCell(iCell)
            if (layerThicknessTarget(k,iCell) < 1.0E-3_RKIND) then
               call mpas_log_write('ALE: iCell $i, k $i: layerThicknessTarget = $r, zBed = $r, ssh = $r', intArgs=(/k, iCell/), &
                                   realArgs=(/layerThicknessTarget(k,iCell), bottomDepth(iCell), projectedSSH(iCell)/))
               err = iCell
            end if
            totalThicknessTarget = totalThicknessTarget + layerThicknessTarget(k,iCell)
         end do
         if (abs(totalThicknessTarget - (bottomDepth(iCell) + projectedSSH(iCell))) > 0.1_RKIND) then
            call mpas_log_write('ALE: iCell $i: totalThickness = $r', intArgs=(/iCell/), realArgs=(/bottomDepth(iCell) + projectedSSH(iCell)/))
            call mpas_log_write('ALE: iCell $i: bottomDepth = $r, ssh = $r', intArgs=(/iCell/), realArgs=(/bottomDepth(iCell), projectedSSH(iCell)/))
            call mpas_log_write('ALE: iCell $i: totalThicknessTarget = $r', intArgs=(/iCell/), realArgs=(/totalThicknessTarget/))
            do k = minLevelCell(iCell), maxLevelCell(iCell)
               call mpas_log_write('ALE: iCell $i: layerThicknessTarget($i) = $r', intArgs=(/iCell, k/), realArgs=(/layerThicknessTarget(minLevelCell(iCell), iCell)/))
               totalThicknessTarget = totalThicknessTarget + layerThicknessTarget(k,iCell)
            end do
            err = iCell
         end if
      end do
      !!$omp end do
      !!$omp end parallel


   end subroutine ocn_vert_regrid


!***********************************************************************
!
!  routine ocn_vert_regrid_init
!
!> \brief   Initializes ocean vertical regridding
!> \author  Carolyn Begeman
!> \date    July 2021
!> \details
!>  This routine initializes parameters required for vertical Lagrangian
!>  regridding
!
!-----------------------------------------------------------------------

   subroutine ocn_vert_regrid_init(err)

      integer, intent(out) :: err !< Output: Error flag

      err = 0

   end subroutine ocn_vert_regrid_init

end module ocn_vertical_regrid
! vim: foldmethod=marker
