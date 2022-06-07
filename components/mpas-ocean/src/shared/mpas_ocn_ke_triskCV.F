! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the
! LICENSE file
! distributed with this code, or at
! http://mpas-dev.github.com/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_ke_triskCV
!
!> \brief MPAS ocean driver for the kinetic energy in TRiSK-CV
!> \author Sara Calandrini
!> \date   17 September 2021
!> \details
!>  This module contains the routines for computing the kinetic 
!>  energy in TRiSK-CV. 
!
!-----------------------------------------------------------------------

module ocn_ke_triskCV

   use mpas_timer
   use mpas_derived_types
   use mpas_pool_routines
   use mpas_constants
   use mpas_threading
   use mpas_vector_reconstruction
   use mpas_stream_manager
   use mpas_io_units
   use mpas_dmpar

   use ocn_constants
   use ocn_config 
   use ocn_thick_ale
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

   public :: Wlsqr, &
             inv_3x3, &
             sphericalTriangleArea, &
             sphere_distance

   !--------------------------------------------------------------------
   !
   ! Private module variables
   !
   !--------------------------------------------------------------------  

!***********************************************************************

contains 

   subroutine inv_3x3(amat,adim,ainv,vdim, adet)

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! inv3x3 computes the inverse of a 3x3 matrix 
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

       implicit none

   !------------------------------------------- arguments !
       integer, intent( in) :: adim
       real (kind=RKIND), intent( in) :: amat(adim,*)
       integer, intent( in) :: vdim
       real (kind=RKIND), intent(out) :: ainv(vdim,*)
       real (kind=RKIND), intent(out) :: adet

   !------------------------------------------- variables !
       real (kind=RKIND) :: &
       aa2233,aa2332,aa2133,aa2331,aa2132, &
       aa2231,aa1233,aa1332,aa1223,aa1322, &
       aa1133,aa1331,aa1123,aa1321,aa1132, &
       aa1231,aa1122,aa1221

   !------------------------------------------- form A^-1 !
       aa2233 = amat(2,2) * amat(3,3)
       aa2332 = amat(2,3) * amat(3,2)
       aa2133 = amat(2,1) * amat(3,3)
       aa2331 = amat(2,3) * amat(3,1)
       aa2132 = amat(2,1) * amat(3,2)
       aa2231 = amat(2,2) * amat(3,1)

       adet =  &
       amat(1,1) *  (aa2233 - aa2332) - &
           amat(1,2) *  (aa2133 - aa2331) + &
           amat(1,3) *  (aa2132 - aa2231)

       aa1233 = amat(1,2) * amat(3,3)
       aa1332 = amat(1,3) * amat(3,2)
       aa1223 = amat(1,2) * amat(2,3)
       aa1322 = amat(1,3) * amat(2,2)
       aa1133 = amat(1,1) * amat(3,3)
       aa1331 = amat(1,3) * amat(3,1)
       aa1123 = amat(1,1) * amat(2,3)
       aa1321 = amat(1,3) * amat(2,1)
       aa1132 = amat(1,1) * amat(3,2)
       aa1231 = amat(1,2) * amat(3,1)
       aa1122 = amat(1,1) * amat(2,2)
       aa1221 = amat(1,2) * amat(2,1)

       ainv(1,1) =  (aa2233 - aa2332)
       ainv(1,2) = -(aa1233 - aa1332)
       ainv(1,3) =  (aa1223 - aa1322)

       ainv(2,1) = -(aa2133 - aa2331)
       ainv(2,2) =  (aa1133 - aa1331)
       ainv(2,3) = -(aa1123 - aa1321)

       ainv(3,1) =  (aa2132 - aa2231)
       ainv(3,2) = -(aa1132 - aa1231)
       ainv(3,3) =  (aa1122 - aa1221)

       return

   end subroutine inv_3x3

   subroutine Wlsqr(domain)

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! buildMatrixBtB computes the least square weightsOnEdge needed for the
   ! computation of the kinetic energy in the TRiSK++ discretization 
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      implicit none

      type (domain_type), intent(inout) :: domain
      integer :: iEdge, jEdge, iEoE, i, j, k, cell1
      integer, dimension(2) :: iEdgeCells, jEdgeCells
      real (kind=RKIND) :: re_x, re_y, re_z, ne_x, ne_y, ne_z, norm, xTangent, yTangent, zTangent, normTangent, detinv   
      real (kind=RKIND), dimension(:), pointer :: areaCVEdge
      real (kind=RKIND), dimension(:,:,:), pointer :: invBtB

      real (kind=RKIND) :: tmat(25,3), matt(3,25), rmat(3,3), rinv(3,3), &
                           rdet, xmul, ymul, zmul
      real (kind=RKIND), dimension(:), allocatable :: elen
      real (kind=RKIND), dimension(:,:), allocatable :: enrm, edir, eprp

      allocate(enrm(nEdgesHalo(3),3))
      allocate(edir(nEdgesAll,3))
      allocate(eprp(nEdgesHalo(3),3))
      allocate(elen(nEdgesAll))

#ifdef MPAS_OPENACC
      !$acc parallel loop gang vector &
      !$acc          present(nEdgesHalo, xVertex, yVertex, zVertex, verticesOnEdge, & 
      !$acc                  xEdge, yEdge, zEdge, sphereRadius, nEdgesOnEdge, & 
      !$acc                  edgesOnEdge, cellsOnEdge, nCellsAll, xCell, yCell, & 
      !$acc                  zCell, weightsOnEdge_lsqr, onSphere) &
      !$acc          private(iEdge, tmat, matt, rmat, rinv, eprp, jEdge, norm, &
      !$acc                  enrm, iEoE, cell1, edir, elen, xmul, ymul, zmul, & 
      !$acc                  rdet)
#else
      !$omp parallel
      !$omp do schedule(runtime) &
      !$omp private(iEdge, tmat, matt, rmat, rinv, eprp, jEdge, norm, &
      !$omp         enrm, iEoE, cell1, edir, elen, xmul, ymul, zmul, &
      !$omp         rdet)
#endif
   !- build lsqr weights for each edge in the mesh
      do iEdge = 1, nEdgesHalo(3)
         tmat(:,:) = 0.0_RKIND
         matt(:,:) = 0.0_RKIND
         rmat(:,:) = 0.0_RKIND
         rinv(:,:) = 0.0_RKIND

      !- unit tangent (on spherical surface) to each edge (in E^3)
         eprp(iEdge,1) = xVertex(verticesOnEdge(2,iEdge)) - &
                    xVertex(verticesOnEdge(1,iEdge))
         eprp(iEdge,2) = yVertex(verticesOnEdge(2,iEdge)) - &
                    yVertex(verticesOnEdge(1,iEdge))
         eprp(iEdge,3) = zVertex(verticesOnEdge(2,iEdge)) - &
                    zVertex(verticesOnEdge(1,iEdge))

         norm = sqrt(eprp(iEdge,1)**2 + eprp(iEdge,2)**2 + eprp(iEdge,3)**2)

         eprp(iEdge,1) = eprp(iEdge,1) / norm
         eprp(iEdge,2) = eprp(iEdge,2) / norm
         eprp(iEdge,3) = eprp(iEdge,3) / norm

      !- unit normals (to spherical surface) at each edge
         if (onSphere) then
            enrm(iEdge,1) = xEdge(iEdge) / sphereRadius
            enrm(iEdge,2) = yEdge(iEdge) / sphereRadius
            enrm(iEdge,3) = zEdge(iEdge) / sphereRadius
         else
            enrm(iEdge,1) = 0.0_RKIND
            enrm(iEdge,2) = 0.0_RKIND
            enrm(iEdge,3) = 1.0_RKIND
         end if

      !- assemble lsqr matrix T: n_hat dot u = u_e
         tmat(1,1) = enrm(iEdge,1)
         tmat(1,2) = enrm(iEdge,2)
         tmat(1,3) = enrm(iEdge,3)

         do jEdge = 1, nEdgesOnEdge(iEdge)

            iEoE = edgesOnEdge(jEdge,iEdge)
            if(iEoE>nEdgesAll) cycle
            if (cellsOnEdge(1,iEoE)>nCellsAll) then
               edir(iEoE,1) = xCell(cellsOnEdge(2,iEoE)) - xEdge(iEoE)
               edir(iEoE,2) = yCell(cellsOnEdge(2,iEoE)) - yEdge(iEoE)
               edir(iEoE,3) = zCell(cellsOnEdge(2,iEoE)) - zEdge(iEoE)
            elseif (cellsOnEdge(2,iEoE)>nCellsAll) then
               edir(iEoE,1) = xEdge(iEoE) - xCell(cellsOnEdge(1,iEoE))
               edir(iEoE,2) = yEdge(iEoE) - yCell(cellsOnEdge(1,iEoE))
               edir(iEoE,3) = zEdge(iEoE) - zCell(cellsOnEdge(1,iEoE))
            else
               edir(iEoE,1) = xCell(cellsOnEdge(2,iEoE)) - &
                            xCell(cellsOnEdge(1,iEoE))
               edir(iEoE,2) = yCell(cellsOnEdge(2,iEoE)) - &
                            yCell(cellsOnEdge(1,iEoE))
               edir(iEoE,3) = zCell(cellsOnEdge(2,iEoE)) - &
                            zCell(cellsOnEdge(1,iEoE))
            end if 

            elen(iEoE) = sqrt(edir(iEoE,1)**2 + edir(iEoE,2)**2 + edir(iEoE,3)**2) 

            edir(iEoE,1) = edir(iEoE,1) / elen(iEoE)
            edir(iEoE,2) = edir(iEoE,2) / elen(iEoE)
            edir(iEoE,3) = edir(iEoE,3) / elen(iEoE)

            tmat(jEdge+1,1) = edir(iEoE,1)
            tmat(jEdge+1,2) = edir(iEoE,2)
            tmat(jEdge+1,3) = edir(iEoE,3)
         end do

      !- form lsqr matrices: (T'*T) * u = T' * u_e
         matt = transpose(tmat)

         rmat = matmul(matt,tmat)

      !- factorise matrices: r_inv = (T'*T) ^ -1
         call inv_3x3(rmat, 3, rinv, 3, rdet)

      !- assemble lsqr weight: t_hat dot r_inv * T'
         do jEdge = 1, nEdgesOnEdge(iEdge)
            xmul = ( &
               rinv(1,1) * matt(1,jEdge+1) + &
               rinv(1,2) * matt(2,jEdge+1) + &
               rinv(1,3) * matt(3,jEdge+1) &
            ) / rdet

            ymul = ( &
               rinv(2,1) * matt(1,jEdge+1) + &
               rinv(2,2) * matt(2,jEdge+1) + &
               rinv(2,3) * matt(3,jEdge+1) &
            ) / rdet

            zmul = ( &
               rinv(3,1) * matt(1,jEdge+1) + &
               rinv(3,2) * matt(2,jEdge+1) + &
               rinv(3,3) * matt(3,jEdge+1) &
            ) / rdet

            weightsOnEdge_lsqr(jEdge,iEdge) = &
               eprp(iEdge,1) * xmul + &
               eprp(iEdge,2) * ymul + &
               eprp(iEdge,3) * zmul 

         end do
      end do
#ifndef MPAS_OPENACC
      !$omp end do
      !$omp end parallel
#endif

      call mpas_dmpar_field_halo_exch(domain, 'weightsOnEdge_lsqr') 

      deallocate(eprp)
      deallocate(edir)
      deallocate(enrm)
      deallocate(elen) 

   end subroutine Wlsqr


   real function sphericalTriangleArea(laEdge, loEdge, laVertex, loVertex, laCell, loCell)

   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! sphericalTriangleArea uses the spherical analog of Heron's formula to
   ! compute the area of a triangle on the surface of a sphere
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      implicit none

      real (kind=RKIND), intent(in) :: laEdge, loEdge, laVertex, loVertex, laCell, loCell
      real (kind=RKIND) :: tanqe, s, a, b, c, one, radius
      one = 1.0
      radius = 6371220.0 

      a = sphere_distance(laCell, loCell, laVertex, loVertex, one)
      b = sphere_distance(laCell, loCell, laEdge, loEdge, one)
      c = sphere_distance(laEdge, loEdge, laVertex, loVertex, one)
      s = 0.5*(a+b+c)
      
      tanqe = sqrt(tan(0.5*s)*tan(0.5*(s-a))*tan(0.5*(s-b))*tan(0.5*(s-c)))
      sphericalTriangleArea = 4.*atan(tanqe)*radius**2 

   end function sphericalTriangleArea

   real function sphere_distance(lat1, lon1, lat2, lon2, radius)
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Compute the great-circle distance between (lat1, lon1) and (lat2, lon2) on
   ! a sphere with given radius.
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      implicit none

      real (kind=RKIND), intent(in) :: lat1, lon1, lat2, lon2, radius

      real (kind=RKIND) :: arg1

      arg1 = sqrt( sin(0.5*(lat2-lat1))**2 +  &
                   cos(lat1)*cos(lat2)*sin(0.5*(lon2-lon1))**2 )
      sphere_distance = 2.*radius*asin(arg1)

   end function sphere_distance


end module ocn_ke_triskCV
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
! vim: foldmethod=marker
