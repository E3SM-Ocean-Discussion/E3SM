module mo_extfrc
  !---------------------------------------------------------------
  ! 	... insitu forcing module
  !---------------------------------------------------------------

  use shr_kind_mod, only : r8 => shr_kind_r8
  use ppgrid,       only : pcols, begchunk, endchunk, pver, pverp
  use chem_mods,    only : gas_pcnst, extcnt
  use spmd_utils,   only : masterproc,iam
  use cam_abortutils,   only : endrun
  use cam_history,  only : addfld, horiz_only, outfld, add_default
  use cam_logfile,  only : iulog
  use tracer_data,  only : trfld,trfile
  use mo_constants, only : avogadro

  implicit none

  type :: forcing
     integer           :: frc_ndx
     real(r8)              :: mw
     character(len=265) :: filename
     real(r8), pointer     :: times(:)
     real(r8), pointer     :: levi(:)
     character(len=8)  :: species
     character(len=8)  :: units
     integer                   :: nsectors
     character(len=32),pointer :: sectors(:)
     type(trfld), pointer      :: fields(:)
     type(trfile)              :: file
  end type forcing

  private
  public  :: extfrc_inti
  public  :: extfrc_set
  public  :: extfrc_timestep_init

  save

  integer, parameter :: time_span = 1

  character(len=256) ::   filename

  logical :: has_extfrc(gas_pcnst)
  type(forcing), allocatable  :: forcings(:)
  integer :: extfrc_cnt = 0

contains

  subroutine extfrc_inti( extfrc_specifier, extfrc_type, extfrc_cycle_yr, extfrc_fixed_ymd, extfrc_fixed_tod, &
                          extfrc_volc_type, extfrc_volc_cycle_yr)

    !-----------------------------------------------------------------------
    ! 	... initialize the surface forcings
    !-----------------------------------------------------------------------
    use cam_pio_utils, only : cam_pio_openfile
    use pio, only : pio_inq_dimid, pio_inquire, pio_inq_varndims, pio_closefile, &
         pio_inq_varname, pio_nowrite, file_desc_t
    use mo_tracname,   only : solsym
    use mo_chem_utls,  only : get_extfrc_ndx, get_spc_ndx
    use chem_mods,     only : frc_from_dataset
    use tracer_data,   only : trcdata_init
    use phys_control,  only : phys_getopts
    use physics_buffer, only : physics_buffer_desc

    implicit none

    !-----------------------------------------------------------------------
    ! 	... dummy arguments
    !-----------------------------------------------------------------------
    character(len=*), dimension(:), intent(in) :: extfrc_specifier
    character(len=*), intent(in) :: extfrc_type
    integer  , intent(in)        :: extfrc_cycle_yr
    integer  , intent(in)        :: extfrc_fixed_ymd
    integer  , intent(in)        :: extfrc_fixed_tod
    character(len=*), intent(in) :: extfrc_volc_type
    integer  , intent(in)        :: extfrc_volc_cycle_yr

    !-----------------------------------------------------------------------
    ! 	... local variables
    !-----------------------------------------------------------------------
    integer :: astat
    integer :: j, l, m, n, i,mm                          ! Indices
    character(len=16)  :: species
    character(len=16)  :: spc_name
    character(len=256) :: locfn
    character(len=256) :: spc_fnames(gas_pcnst)

    integer ::  vid, ndims, nvars, isec, ierr
    type(file_desc_t) :: ncid
    character(len=32)  :: varname

    character(len=1), parameter :: filelist = ''
    character(len=1), parameter :: datapath = ''
    logical         , parameter :: rmv_file = .false.
    logical  :: history_aerosol      ! Output the MAM aerosol tendencies
    logical  :: history_verbose      ! produce verbose history output
! chem diags
    logical  :: history_gaschmbudget_2D
    logical  :: history_chemdyg_summary
    !-----------------------------------------------------------------------
 
    call phys_getopts( history_aerosol_out        = history_aerosol, &
                       history_verbose_out        = history_verbose, &
                       history_gaschmbudget_2D_out = history_gaschmbudget_2D, &
                       history_chemdyg_summary_out = history_chemdyg_summary   )

    do i = 1, gas_pcnst
       has_extfrc(i) = .false.
       spc_fnames(i) = ''
    enddo

    !-----------------------------------------------------------------------
    ! 	... species has insitu forcing ?
    !-----------------------------------------------------------------------

    !write(iulog,*) 'Species with insitu forcings'

    count_emis: do n=1,gas_pcnst

       if ( len_trim(extfrc_specifier(n) ) == 0 ) then
          exit count_emis
       endif

       i = scan(extfrc_specifier(n),'->')
       spc_name = trim(adjustl(extfrc_specifier(n)(:i-1)))
       filename = trim(adjustl(extfrc_specifier(n)(i+2:)))

       m = get_extfrc_ndx( spc_name )

       if ( m < 1 ) then
          call endrun('extfrc_inti: '//trim(spc_name)// ' does not have an external source')
       endif

       if ( .not. frc_from_dataset(m) ) then
          call endrun('extfrc_inti: '//trim(spc_name)//' cannot have external forcing from additional dataset')
       endif

       mm = get_spc_ndx(spc_name)
       spc_fnames(mm) = filename

       has_extfrc(mm) = .true.
       !write(iulog,*) '   ',  spc_name ,' : filename = ',trim(spc_fnames(mm)),' spc ndx = ',mm

    enddo count_emis

    extfrc_cnt = count( has_extfrc(:) )

    if( extfrc_cnt < 1 ) then
       if (masterproc) write(iulog,*) 'There are no species with insitu forcings'
       return
    end if

    if (masterproc) write(iulog,*) ' '

    !-----------------------------------------------------------------------
    ! 	... allocate forcings type array
    !-----------------------------------------------------------------------
    allocate( forcings(extfrc_cnt), stat=astat )
    if( astat/= 0 ) then
       write(iulog,*) 'extfrc_inti: failed to allocate forcings array; error = ',astat
       call endrun
    end if

    !-----------------------------------------------------------------------
    ! 	... setup the forcing type array
    !-----------------------------------------------------------------------
    n = 0
    species_loop : do m = 1,gas_pcnst
       has_forcing : if( has_extfrc(m) ) then
          spc_name = trim( solsym(m) )
          n        = n + 1
          !-----------------------------------------------------------------------
          ! 	... default settings
          !-----------------------------------------------------------------------
          forcings(n)%frc_ndx          = get_extfrc_ndx( spc_name )
          forcings(n)%species          = spc_name
          forcings(n)%filename         = spc_fnames(m)
          call addfld( trim(spc_name)//'_XFRC', (/ 'lev' /), 'A',  'molec/cm3/s', &
                       'external forcing for '//trim(spc_name) )
          call addfld( trim(spc_name)//'_CLXF', horiz_only, 'A',  'molec/cm2/s', &
                       'vertically intergrated external forcing for '//trim(spc_name) )
          if ( history_aerosol ) then 
             if (history_verbose) call add_default( trim(spc_name)//'_XFRC', 1, ' ' )
             call add_default( trim(spc_name)//'_CLXF', 1, ' ' )
          endif
       end if has_forcing
    end do species_loop

    if (history_gaschmbudget_2D .or. history_chemdyg_summary) then
       call addfld( 'NO2_TDAcf', (/ 'lev' /), 'A',  'kg N/m2/s', &
                       'external forcing for NO2 aircraft emission' )
       call add_default( 'NO2_TDAcf', 1, ' ' )
    endif

    if (masterproc) then
       !-----------------------------------------------------------------------
       ! 	... diagnostics
       !-----------------------------------------------------------------------
       write(iulog,*) ' '
       write(iulog,*) 'extfrc_inti: diagnostics'
       write(iulog,*) ' '
       write(iulog,*) 'extfrc timing specs'
       write(iulog,*) 'type = ',extfrc_type
       if( extfrc_type == 'FIXED' ) then
          write(iulog,*) ' fixed date = ', extfrc_fixed_ymd
          write(iulog,*) ' fixed time = ', extfrc_fixed_tod
       else if( extfrc_type == 'CYCLICAL' ) then
          write(iulog,*) ' cycle year = ',extfrc_cycle_yr
       end if
       if (extfrc_volc_type /= 'NULL' ) then
          write(iulog,*) ' '
          write(iulog,*) 'Volcanic SO2 type = ',extfrc_volc_type
          if (extfrc_volc_type  == 'CYCLICAL' ) then
              write(iulog,*) ' '
              write(iulog,*) 'Volcanic SO2 cycle year = ',extfrc_volc_cycle_yr
          end if
       end if
       write(iulog,*) ' '
       write(iulog,*) 'there are ',extfrc_cnt,' species with external forcing files'
       do m = 1,extfrc_cnt
          write(iulog,*) ' '
          write(iulog,*) 'forcing type ',m
          write(iulog,*) 'species = ',trim(forcings(m)%species)
          write(iulog,*) 'frc ndx = ',forcings(m)%frc_ndx
          write(iulog,*) 'filename= ',trim(forcings(m)%filename)
       end do
       write(iulog,*) ' '
    endif

    !-----------------------------------------------------------------------
    ! read emis files to determine number of sectors
    !-----------------------------------------------------------------------
    frcing_loop: do m = 1, extfrc_cnt

       forcings(m)%nsectors = 0

       call cam_pio_openfile ( ncid, trim(forcings(m)%filename), PIO_NOWRITE)
       ierr = pio_inquire (ncid, nVariables=nvars)

       do vid = 1,nvars

          ierr = pio_inq_varndims (ncid, vid, ndims)

          if( ndims < 4 ) then
             cycle
          elseif( ndims > 4 ) then
             ierr = pio_inq_varname (ncid, vid, varname)
             write(iulog,*) 'extfrc_inti: Skipping variable ', trim(varname),', ndims = ',ndims, &
                  ' , species=',trim(forcings(m)%species)
             cycle
          end if

          forcings(m)%nsectors = forcings(m)%nsectors+1

       enddo

       allocate( forcings(m)%sectors(forcings(m)%nsectors), stat=astat )
       if( astat/= 0 ) then
         write(iulog,*) 'extfrc_inti: failed to allocate forcings(m)%sectors array; error = ',astat
         call endrun
       end if

       isec = 1
       do vid = 1,nvars

          ierr = pio_inq_varndims (ncid, vid, ndims)
          if( ndims == 4 ) then
             ierr = pio_inq_varname(ncid, vid, forcings(m)%sectors(isec))
             isec = isec+1
          endif

       enddo

       call pio_closefile (ncid)

       allocate(forcings(m)%file%in_pbuf(size(forcings(m)%sectors)))
       forcings(m)%file%in_pbuf(:) = .false.
       if (trim(forcings(m)%species) == 'SO2' .and. extfrc_volc_type /= 'NULL') then
          call trcdata_init( forcings(m)%sectors, &
                             forcings(m)%filename, filelist, datapath, &
                             forcings(m)%fields,  &
                             forcings(m)%file, rmv_file, extfrc_volc_cycle_yr, &
                             extfrc_fixed_ymd, extfrc_fixed_tod, extfrc_volc_type)
       else
          call trcdata_init( forcings(m)%sectors, &
                             forcings(m)%filename, filelist, datapath, &
                             forcings(m)%fields,  &
                             forcings(m)%file, &
                             rmv_file, extfrc_cycle_yr, extfrc_fixed_ymd, extfrc_fixed_tod, extfrc_type)
       end if

    enddo frcing_loop


  end subroutine extfrc_inti

  subroutine extfrc_timestep_init( pbuf2d, state )
    !-----------------------------------------------------------------------
    !       ... check serial case for time span
    !-----------------------------------------------------------------------

    use physics_types,only : physics_state
    use ppgrid,       only : begchunk, endchunk
    use tracer_data,  only : advance_trcdata
    use physics_buffer, only : physics_buffer_desc

    implicit none

    type(physics_state), intent(in):: state(begchunk:endchunk)                 
    type(physics_buffer_desc), pointer :: pbuf2d(:,:)

    !-----------------------------------------------------------------------
    !       ... local variables
    !-----------------------------------------------------------------------
    integer :: m

    do m = 1,extfrc_cnt
       call advance_trcdata( forcings(m)%fields, forcings(m)%file, state, pbuf2d  )
    end do

  end subroutine extfrc_timestep_init

  subroutine extfrc_set( lchnk, zint, frcing, ncol )
    use phys_control,  only : phys_getopts
    !--------------------------------------------------------
    !	... form the external forcing
    !--------------------------------------------------------

    implicit none

    !--------------------------------------------------------
    !	... dummy arguments
    !--------------------------------------------------------
    integer,  intent(in)    :: ncol                  ! columns in chunk
    integer,  intent(in)    :: lchnk                 ! chunk index
    real(r8), intent(in)    :: zint(ncol, pverp)                  ! interface geopot above surface (km)
    real(r8), intent(inout) :: frcing(ncol,pver,extcnt)   ! insitu forcings (molec/cm^3/s)

    !--------------------------------------------------------
    !	... local variables
    !--------------------------------------------------------
    integer  ::  i, m, n
    character(len=16) :: xfcname
    real(r8) :: frcing_col(1:ncol), frcing_tmp(ncol,pver), no2_tdacf(ncol,pver)
    integer  :: k, isec
    real(r8),parameter :: km_to_cm = 1.e5_r8
    !chem diags
    logical  :: history_gaschmbudget_2D
    logical  :: history_chemdyg_summary

    call phys_getopts(history_gaschmbudget_2D_out = history_gaschmbudget_2D,&
                      history_chemdyg_summary_out = history_chemdyg_summary   )

    if( extfrc_cnt < 1 .or. extcnt < 1 ) then
       return
    end if

    !--------------------------------------------------------
    !	... set non-zero forcings
    !--------------------------------------------------------
    src_loop : do m = 1,extfrc_cnt

      n = forcings(m)%frc_ndx

       frcing(:ncol,:,n) = 0._r8
       do isec = 1,forcings(m)%nsectors
          if (forcings(m)%file%alt_data) then
             frcing(:ncol,:,n) = frcing(:ncol,:,n) + forcings(m)%fields(isec)%data(:ncol,pver:1:-1,lchnk)
          else
             frcing(:ncol,:,n) = frcing(:ncol,:,n) + forcings(m)%fields(isec)%data(:ncol,:,lchnk)
          endif
       enddo

       xfcname = trim(forcings(m)%species)//'_XFRC'
       call outfld( xfcname, frcing(:ncol,:,n), ncol, lchnk )

       frcing_col(:ncol) = 0._r8
       frcing_tmp(:ncol,:) = 0._r8
       if (trim(forcings(m)%species) == 'NO2') then
       if (history_gaschmbudget_2D .or. history_chemdyg_summary) then
            no2_tdacf(:ncol,:) = 0._r8
       endif
       endif
       do k = 1,pver
          frcing_tmp(:ncol,k) = frcing(:ncol,k,n)*(zint(:ncol,k)-zint(:ncol,k+1))*km_to_cm
          frcing_col(:ncol) = frcing_col(:ncol) + frcing_tmp(:ncol,k)
          !frcing_col(:ncol) = frcing_col(:ncol) + frcing(:ncol,k,n)*(zint(:ncol,k)-zint(:ncol,k+1))*km_to_cm

          if (trim(forcings(m)%species) == 'NO2') then
          if (history_gaschmbudget_2D .or. history_chemdyg_summary) then
          !kgn per m2 per second: 1/avogadro * 14.00674 * 1.e-3 * 1.e4
               no2_tdacf(:ncol,k) = frcing_tmp(:ncol,k)/avogadro * 14.00674_r8  * 10._r8 

          endif
          endif
       enddo

       if (trim(forcings(m)%species) == 'NO2') then
       if (history_gaschmbudget_2D .or. history_chemdyg_summary) then
            call outfld('NO2_TDAcf', no2_tdacf(:ncol,:), ncol, lchnk )
       endif
       endif

       xfcname = trim(forcings(m)%species)//'_CLXF'
       call outfld( xfcname, frcing_col(:ncol), ncol, lchnk )

    end do src_loop

  end subroutine extfrc_set


end module mo_extfrc
