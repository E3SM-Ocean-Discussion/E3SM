module mpaso_cpl_indices
  
  use seq_flds_mod
  use mct_mod

  implicit none

  SAVE
  public                               ! By default make data private

  integer , parameter, private:: glc_nzoc_max = 100

  ! ocn -> drv

  integer :: index_o2x_So_t      
  integer :: index_o2x_So_u
  integer :: index_o2x_So_v
  integer :: index_o2x_So_s
  integer :: index_o2x_So_dhdx
  integer :: index_o2x_So_dhdy
  integer :: index_o2x_Fioo_q
  integer :: index_o2x_Foxo_q_li
  integer :: index_o2x_Fioo_frazil
  integer :: index_o2x_Foxo_frazil_li
  integer :: index_o2x_Faoo_h2otemp
  integer :: index_o2x_Faoo_fco2_ocn
  integer :: index_o2x_Faoo_fdms_ocn
  integer :: index_o2x_So_ssh
  integer :: index_o2x_Foxo_ismw
  integer :: index_o2x_Foxo_rrofl
  integer :: index_o2x_Foxo_rrofi
  integer :: index_o2x_Foxo_ismh
  integer :: index_o2x_Foxo_rrofih

  ! ocn -> drv for calculation of ocean-ice sheet interactions

  integer :: index_o2x_So_blt !boundary layer temperature
  integer :: index_o2x_So_bls !boundary layer salinity
  integer :: index_o2x_So_htv !ocean heat-transfer velocity
  integer :: index_o2x_So_stv !ocean salt-transfer velocity
  integer :: index_o2x_So_rhoeff !ocean effective density
  integer :: index_o2x_So_tf3d(glc_nzoc_max) !ocean thermal forcing at predefined z-levels
  integer :: index_o2x_So_tf3d_mask(glc_nzoc_max) !mask ofocean thermal forcing at predefined z-levels



  ! ocn -> drv  (BGC)

  integer :: index_o2x_So_algae1
  integer :: index_o2x_So_algae2
  integer :: index_o2x_So_algae3
  integer :: index_o2x_So_doc1
  integer :: index_o2x_So_doc2
  integer :: index_o2x_So_doc3
  integer :: index_o2x_So_dic1
  integer :: index_o2x_So_don1
  integer :: index_o2x_So_no3
  integer :: index_o2x_So_sio3
  integer :: index_o2x_So_nh4
  integer :: index_o2x_So_dms
  integer :: index_o2x_So_dmsp
  integer :: index_o2x_So_docr
  integer :: index_o2x_So_fep1
  integer :: index_o2x_So_fep2
  integer :: index_o2x_So_fed1
  integer :: index_o2x_So_fed2
  integer :: index_o2x_So_zaer1
  integer :: index_o2x_So_zaer2
  integer :: index_o2x_So_zaer3
  integer :: index_o2x_So_zaer4
  integer :: index_o2x_So_zaer5
  integer :: index_o2x_So_zaer6

  ! drv -> ocn

  integer :: index_x2o_Si_ifrac        ! fractional ice wrt ocean
  integer :: index_x2o_Si_bpress       ! ice basal pressure
  integer :: index_x2o_So_duu10n       ! 10m wind speed squared           (m^2/s^2)
  integer :: index_x2o_Sa_pslv         ! atmospheric sea level pressure   (Pa)
  integer :: index_x2o_Sa_co2prog      ! bottom atm level prognostic CO2
  integer :: index_x2o_Sa_co2diag      ! bottom atm level diagnostic CO2
  integer :: index_x2o_Foxx_taux       ! zonal wind stress (taux)         (W/m2   )
  integer :: index_x2o_Foxx_tauy       ! meridonal wind stress (tauy)     (W/m2   )
  integer :: index_x2o_Foxx_swnet      ! net short-wave heat flux         (W/m2   )
  integer :: index_x2o_Foxx_sen        ! sensible heat flux               (W/m2   )
  integer :: index_x2o_Foxx_lat        
  integer :: index_x2o_Foxx_lwup       ! longwave radiation (up)          (W/m2   )
  integer :: index_x2o_Faxa_lwdn       ! longwave radiation (down)        (W/m2   )
  integer :: index_x2o_Fioi_melth      ! heat flux from snow & ice melt   (W/m2   )
  integer :: index_x2o_Fioi_meltw      ! snow melt flux                   (kg/m2/s)
  integer :: index_x2o_Fioi_bergh      ! heat flux from iceberg melt      (W/m2   )
  integer :: index_x2o_Fioi_bergw      ! iceberg melt flux                (kg/m2/s)
  integer :: index_x2o_Fioi_salt       ! salt                             (kg(salt)/m2/s)
  integer :: index_x2o_Foxx_evap       ! evaporation flux                 (kg/m2/s)
  integer :: index_x2o_Faxa_prec         
  integer :: index_x2o_Faxa_snow       ! water flux due to snow           (kg/m2/s)
  integer :: index_x2o_Faxa_rain       ! water flux due to rain           (kg/m2/s)
  integer :: index_x2o_Faxa_bcphidry   ! flux: Black   Carbon hydrophilic dry deposition
  integer :: index_x2o_Faxa_bcphodry   ! flux: Black   Carbon hydrophobic dry deposition
  integer :: index_x2o_Faxa_bcphiwet   ! flux: Black   Carbon hydrophilic wet deposition
  integer :: index_x2o_Faxa_ocphidry   ! flux: Organic Carbon hydrophilic dry deposition
  integer :: index_x2o_Faxa_ocphodry   ! flux: Organic Carbon hydrophobic dry deposition
  integer :: index_x2o_Faxa_ocphiwet   ! flux: Organic Carbon hydrophilic dry deposition
  integer :: index_x2o_Faxa_dstwet1    ! flux: Size 1 dust -- wet deposition
  integer :: index_x2o_Faxa_dstwet2    ! flux: Size 2 dust -- wet deposition
  integer :: index_x2o_Faxa_dstwet3    ! flux: Size 3 dust -- wet deposition
  integer :: index_x2o_Faxa_dstwet4    ! flux: Size 4 dust -- wet deposition
  integer :: index_x2o_Faxa_dstdry1    ! flux: Size 1 dust -- dry deposition
  integer :: index_x2o_Faxa_dstdry2    ! flux: Size 2 dust -- dry deposition
  integer :: index_x2o_Faxa_dstdry3    ! flux: Size 3 dust -- dry deposition
  integer :: index_x2o_Faxa_dstdry4    ! flux: Size 4 dust -- dry deposition
  integer :: index_x2o_Foxx_rofl       ! river runoff flux                (kg/m2/s)
  integer :: index_x2o_Foxx_rofi       ! ice runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDIN     ! DIN runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDIP     ! DIP runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDON     ! DON runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDOP     ! DOP runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDOC     ! DOC runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofPP      ! PP  runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDSi     ! DSi runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofPOC     ! POC runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofPN      ! PN  runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofDIC     ! DIC runoff flux                  (kg/m2/s)
  integer :: index_x2o_Foxx_rofFe      ! Fe  runoff flux                  (kg/m2/s)
  integer :: index_x2o_Sw_ustokes_wavenumber_1      ! partitioned Stokes drift wavenumber 1 
  integer :: index_x2o_Sw_vstokes_wavenumber_1      ! partitioned Stokes drift wavenumber 1
  integer :: index_x2o_Sw_ustokes_wavenumber_2      ! partitioned Stokes drift wavenumber 2 
  integer :: index_x2o_Sw_vstokes_wavenumber_2      ! partitioned Stokes drift wavenumber 2
  integer :: index_x2o_Sw_ustokes_wavenumber_3      ! partitioned Stokes drift wavenumber 3 
  integer :: index_x2o_Sw_vstokes_wavenumber_3      ! partitioned Stokes drift wavenumber 3
  integer :: index_x2o_Sw_ustokes_wavenumber_4      ! partitioned Stokes drift wavenumber 4 
  integer :: index_x2o_Sw_vstokes_wavenumber_4      ! partitioned Stokes drift wavenumber 4
  integer :: index_x2o_Sw_ustokes_wavenumber_5      ! partitioned Stokes drift wavenumber 5 
  integer :: index_x2o_Sw_vstokes_wavenumber_5      ! partitioned Stokes drift wavenumber 5
  integer :: index_x2o_Sw_ustokes_wavenumber_6      ! partitioned Stokes drift wavenumber 6 
  integer :: index_x2o_Sw_vstokes_wavenumber_6      ! partitioned Stokes drift wavenumber 6
  integer :: index_x2o_Sw_Hs         ! Significant wave height
  integer :: index_x2o_Sw_Fp         ! Peak wave frequency
  integer :: index_x2o_Sw_Dp         ! Peak wave direction

  ! drv -> glc and internal drv fields

  integer :: index_x2o_Fogx_qicelo
  integer :: index_x2o_Fogx_qiceho
  integer :: index_x2o_Sg_blit
  integer :: index_x2o_Sg_blis
  integer :: index_x2o_Sg_lithop
  integer :: index_x2o_Sg_icemask
  integer :: index_x2o_Sg_icemask_grounded
  integer :: index_x2o_Sg_icemask_floating


  ! drv -> ocn (BGC)

  integer :: index_x2o_Fioi_algae1
  integer :: index_x2o_Fioi_algae2
  integer :: index_x2o_Fioi_algae3
  integer :: index_x2o_Fioi_doc1
  integer :: index_x2o_Fioi_doc2
  integer :: index_x2o_Fioi_doc3
  integer :: index_x2o_Fioi_dic1
  integer :: index_x2o_Fioi_don1
  integer :: index_x2o_Fioi_no3
  integer :: index_x2o_Fioi_sio3
  integer :: index_x2o_Fioi_nh4
  integer :: index_x2o_Fioi_dms
  integer :: index_x2o_Fioi_dmspp
  integer :: index_x2o_Fioi_dmspd
  integer :: index_x2o_Fioi_docr
  integer :: index_x2o_Fioi_fep1
  integer :: index_x2o_Fioi_fep2
  integer :: index_x2o_Fioi_fed1
  integer :: index_x2o_Fioi_fed2
  integer :: index_x2o_Fioi_dust1

contains

  subroutine mpaso_cpl_indices_set( )

    use seq_flds_mod, only : wav_ocn_coup      
    use glc_zocnclass_mod

    type(mct_aVect) :: o2x      ! temporary
    type(mct_aVect) :: x2o      ! temporary

    integer :: glc_nzoc
    integer :: iLev
    character(len=2) :: cnum
    character(len=64) :: varname

    glc_nzoc = glc_get_num_zocn_classes()

    ! Determine attribute vector indices

    ! create temporary attribute vectors
    call mct_aVect_init(x2o, rList=seq_flds_x2o_fields, lsize=1)
    call mct_aVect_init(o2x, rList=seq_flds_o2x_fields, lsize=1)

    index_o2x_So_t          = mct_avect_indexra(o2x,'So_t')
    index_o2x_So_u          = mct_avect_indexra(o2x,'So_u')
    index_o2x_So_v          = mct_avect_indexra(o2x,'So_v')
    index_o2x_So_s          = mct_avect_indexra(o2x,'So_s')
    index_o2x_So_dhdx       = mct_avect_indexra(o2x,'So_dhdx')
    index_o2x_So_dhdy       = mct_avect_indexra(o2x,'So_dhdy')
    index_o2x_Fioo_q        = mct_avect_indexra(o2x,'Fioo_q',perrWith='quiet')
    index_o2x_Foxo_q_li     = mct_avect_indexra(o2x,'Foxo_q_li',perrWith='quiet')
    index_o2x_Fioo_frazil   = mct_avect_indexra(o2x,'Fioo_frazil',perrWith='quiet')
    index_o2x_Foxo_frazil_li= mct_avect_indexra(o2x,'Foxo_frazil_li',perrWith='quiet')
    index_o2x_Faoo_h2otemp  = mct_avect_indexra(o2x,'Faoo_h2otemp',perrWith='quiet')
    index_o2x_Faoo_fco2_ocn = mct_avect_indexra(o2x,'Faoo_fco2_ocn',perrWith='quiet')
    index_o2x_Faoo_fdms_ocn = mct_avect_indexra(o2x,'Faoo_fdms_ocn',perrWith='quiet')
    index_o2x_So_ssh        = mct_avect_indexra(o2x,'So_ssh')

    index_o2x_Foxo_ismw     = mct_avect_indexra(o2x,'Foxo_ismw',perrWith='quiet')
    index_o2x_Foxo_rrofl    = mct_avect_indexra(o2x,'Foxo_rrofl',perrWith='quiet')
    index_o2x_Foxo_rrofi    = mct_avect_indexra(o2x,'Foxo_rrofi',perrWith='quiet')

    index_o2x_Foxo_ismh     = mct_avect_indexra(o2x,'Foxo_ismh',perrWith='quiet')
    index_o2x_Foxo_rrofih   = mct_avect_indexra(o2x,'Foxo_rrofih',perrWith='quiet')

    index_o2x_So_blt        = mct_avect_indexra(o2x,'So_blt')
    index_o2x_So_bls        = mct_avect_indexra(o2x,'So_bls')
    index_o2x_So_htv        = mct_avect_indexra(o2x,'So_htv')
    index_o2x_So_stv        = mct_avect_indexra(o2x,'So_stv')
    index_o2x_So_rhoeff     = mct_avect_indexra(o2x,'So_rhoeff')
    if (glc_nzoc > 0) then
       do iLev = 1, glc_nzoc
          cnum = glc_zocnclass_as_string(iLev)
          varname = 'So_tf3d' // cnum
          index_o2x_So_tf3d(iLev) = mct_avect_indexra(o2x, trim(varname))

          varname = 'So_tf3d_mask' // cnum
          index_o2x_So_tf3d_mask(iLev) = mct_avect_indexra(o2x, trim(varname))
       enddo
    endif

    index_o2x_So_algae1     = mct_avect_indexra(o2x,'So_algae1',perrWith='quiet')
    index_o2x_So_algae2     = mct_avect_indexra(o2x,'So_algae2',perrWith='quiet')
    index_o2x_So_algae3     = mct_avect_indexra(o2x,'So_algae3',perrWith='quiet')
    index_o2x_So_doc1       = mct_avect_indexra(o2x,'So_doc1',perrWith='quiet')
    index_o2x_So_doc2       = mct_avect_indexra(o2x,'So_doc2',perrWith='quiet')
    index_o2x_So_doc3       = mct_avect_indexra(o2x,'So_doc3',perrWith='quiet')
    index_o2x_So_dic1       = mct_avect_indexra(o2x,'So_dic1',perrWith='quiet')
    index_o2x_So_don1       = mct_avect_indexra(o2x,'So_don1',perrWith='quiet')
    index_o2x_So_no3        = mct_avect_indexra(o2x,'So_no3',perrWith='quiet')
    index_o2x_So_sio3       = mct_avect_indexra(o2x,'So_sio3',perrWith='quiet')
    index_o2x_So_nh4        = mct_avect_indexra(o2x,'So_nh4',perrWith='quiet')
    index_o2x_So_dms        = mct_avect_indexra(o2x,'So_dms',perrWith='quiet')
    index_o2x_So_dmsp       = mct_avect_indexra(o2x,'So_dmsp',perrWith='quiet')
    index_o2x_So_docr       = mct_avect_indexra(o2x,'So_docr',perrWith='quiet')
    index_o2x_So_fep1       = mct_avect_indexra(o2x,'So_fep1',perrWith='quiet')
    index_o2x_So_fep2       = mct_avect_indexra(o2x,'So_fep2',perrWith='quiet')
    index_o2x_So_fed1       = mct_avect_indexra(o2x,'So_fed1',perrWith='quiet')
    index_o2x_So_fed2       = mct_avect_indexra(o2x,'So_fed2',perrWith='quiet')
    index_o2x_So_zaer1      = mct_avect_indexra(o2x,'So_zaer1',perrWith='quiet')
    index_o2x_So_zaer2      = mct_avect_indexra(o2x,'So_zaer2',perrWith='quiet')
    index_o2x_So_zaer3      = mct_avect_indexra(o2x,'So_zaer3',perrWith='quiet')
    index_o2x_So_zaer4      = mct_avect_indexra(o2x,'So_zaer4',perrWith='quiet')
    index_o2x_So_zaer5      = mct_avect_indexra(o2x,'So_zaer5',perrWith='quiet')
    index_o2x_So_zaer6      = mct_avect_indexra(o2x,'So_zaer6',perrWith='quiet')

    index_x2o_Si_ifrac      = mct_avect_indexra(x2o,'Si_ifrac')
    index_x2o_Si_bpress     = mct_avect_indexra(x2o,'Si_bpress')
    index_x2o_Sa_pslv       = mct_avect_indexra(x2o,'Sa_pslv')
    index_x2o_So_duu10n     = mct_avect_indexra(x2o,'So_duu10n')
    index_x2o_Foxx_tauy     = mct_avect_indexra(x2o,'Foxx_tauy')
    index_x2o_Foxx_taux     = mct_avect_indexra(x2o,'Foxx_taux')
    index_x2o_Foxx_swnet    = mct_avect_indexra(x2o,'Foxx_swnet')
    index_x2o_Foxx_lat      = mct_avect_indexra(x2o,'Foxx_lat')
    index_x2o_Foxx_sen      = mct_avect_indexra(x2o,'Foxx_sen')
    index_x2o_Foxx_lwup     = mct_avect_indexra(x2o,'Foxx_lwup')
    index_x2o_Faxa_lwdn     = mct_avect_indexra(x2o,'Faxa_lwdn')
    index_x2o_Fioi_melth    = mct_avect_indexra(x2o,'Fioi_melth')   
    index_x2o_Fioi_meltw    = mct_avect_indexra(x2o,'Fioi_meltw')
    index_x2o_Fioi_bergh    = mct_avect_indexra(x2o,'PFioi_bergh')
    index_x2o_Fioi_bergw    = mct_avect_indexra(x2o,'PFioi_bergw')
    index_x2o_Fioi_salt     = mct_avect_indexra(x2o,'Fioi_salt')   
    index_x2o_Faxa_prec     = mct_avect_indexra(x2o,'Faxa_prec')   
    index_x2o_Faxa_snow     = mct_avect_indexra(x2o,'Faxa_snow')   
    index_x2o_Faxa_rain     = mct_avect_indexra(x2o,'Faxa_rain')   
    index_x2o_Foxx_evap     = mct_avect_indexra(x2o,'Foxx_evap')
    index_x2o_Foxx_rofl     = mct_avect_indexra(x2o,'Foxx_rofl')
    index_x2o_Foxx_rofi     = mct_avect_indexra(x2o,'Foxx_rofi')
    if (rof2ocn_nutrients) then
       index_x2o_Foxx_rofDIN   = mct_avect_indexra(x2o,'Foxx_rofDIN')
       index_x2o_Foxx_rofDIP   = mct_avect_indexra(x2o,'Foxx_rofDIP')
       index_x2o_Foxx_rofDON   = mct_avect_indexra(x2o,'Foxx_rofDON')
       index_x2o_Foxx_rofDOP   = mct_avect_indexra(x2o,'Foxx_rofDOP')
       index_x2o_Foxx_rofDOC   = mct_avect_indexra(x2o,'Foxx_rofDOC')
       index_x2o_Foxx_rofPP    = mct_avect_indexra(x2o,'Foxx_rofPP')
       index_x2o_Foxx_rofDSi   = mct_avect_indexra(x2o,'Foxx_rofDSi')
       index_x2o_Foxx_rofPOC   = mct_avect_indexra(x2o,'Foxx_rofPOC')
       index_x2o_Foxx_rofPN    = mct_avect_indexra(x2o,'Foxx_rofPN')
       index_x2o_Foxx_rofDIC   = mct_avect_indexra(x2o,'Foxx_rofDIC')
       index_x2o_Foxx_rofFe    = mct_avect_indexra(x2o,'Foxx_rofFe')
    endif
    index_x2o_Faxa_bcphidry = mct_avect_indexra(x2o,'Faxa_bcphidry')
    index_x2o_Faxa_bcphodry = mct_avect_indexra(x2o,'Faxa_bcphodry')
    index_x2o_Faxa_bcphiwet = mct_avect_indexra(x2o,'Faxa_bcphiwet')
    index_x2o_Faxa_ocphidry = mct_avect_indexra(x2o,'Faxa_ocphidry')
    index_x2o_Faxa_ocphodry = mct_avect_indexra(x2o,'Faxa_ocphodry')
    index_x2o_Faxa_ocphiwet = mct_avect_indexra(x2o,'Faxa_ocphiwet')
    index_x2o_Faxa_dstdry1  = mct_avect_indexra(x2o,'Faxa_dstdry1')
    index_x2o_Faxa_dstdry2  = mct_avect_indexra(x2o,'Faxa_dstdry2')
    index_x2o_Faxa_dstdry3  = mct_avect_indexra(x2o,'Faxa_dstdry3')
    index_x2o_Faxa_dstdry4  = mct_avect_indexra(x2o,'Faxa_dstdry4')
    index_x2o_Faxa_dstwet1  = mct_avect_indexra(x2o,'Faxa_dstwet1')
    index_x2o_Faxa_dstwet2  = mct_avect_indexra(x2o,'Faxa_dstwet2')
    index_x2o_Faxa_dstwet3  = mct_avect_indexra(x2o,'Faxa_dstwet3')
    index_x2o_Faxa_dstwet4  = mct_avect_indexra(x2o,'Faxa_dstwet4')
    index_x2o_Sa_co2prog    = mct_avect_indexra(x2o,'Sa_co2prog',perrWith='quiet')
    index_x2o_Sa_co2diag    = mct_avect_indexra(x2o,'Sa_co2diag',perrWith='quiet')

    index_x2o_Fioi_algae1   = mct_avect_indexra(x2o,'Fioi_algae1',perrWith='quiet')
    index_x2o_Fioi_algae2   = mct_avect_indexra(x2o,'Fioi_algae2',perrWith='quiet')
    index_x2o_Fioi_algae3   = mct_avect_indexra(x2o,'Fioi_algae3',perrWith='quiet')
    index_x2o_Fioi_doc1     = mct_avect_indexra(x2o,'Fioi_doc1',perrWith='quiet')
    index_x2o_Fioi_doc2     = mct_avect_indexra(x2o,'Fioi_doc2',perrWith='quiet')
    index_x2o_Fioi_doc3     = mct_avect_indexra(x2o,'Fioi_doc3',perrWith='quiet')
    index_x2o_Fioi_dic1     = mct_avect_indexra(x2o,'Fioi_dic1',perrWith='quiet')
    index_x2o_Fioi_don1     = mct_avect_indexra(x2o,'Fioi_don1',perrWith='quiet')
    index_x2o_Fioi_no3      = mct_avect_indexra(x2o,'Fioi_no3',perrWith='quiet')
    index_x2o_Fioi_sio3     = mct_avect_indexra(x2o,'Fioi_sio3',perrWith='quiet')
    index_x2o_Fioi_nh4      = mct_avect_indexra(x2o,'Fioi_nh4',perrWith='quiet')
    index_x2o_Fioi_dms      = mct_avect_indexra(x2o,'Fioi_dms',perrWith='quiet')
    index_x2o_Fioi_dmspp    = mct_avect_indexra(x2o,'Fioi_dmspp',perrWith='quiet')
    index_x2o_Fioi_dmspd    = mct_avect_indexra(x2o,'Fioi_dmspd',perrWith='quiet')
    index_x2o_Fioi_docr     = mct_avect_indexra(x2o,'Fioi_docr',perrWith='quiet')
    index_x2o_Fioi_fep1     = mct_avect_indexra(x2o,'Fioi_fep1',perrWith='quiet')
    index_x2o_Fioi_fep2     = mct_avect_indexra(x2o,'Fioi_fep2',perrWith='quiet')
    index_x2o_Fioi_fed1     = mct_avect_indexra(x2o,'Fioi_fed1',perrWith='quiet')
    index_x2o_Fioi_fed2     = mct_avect_indexra(x2o,'Fioi_fed2',perrWith='quiet')
    index_x2o_Fioi_dust1    = mct_avect_indexra(x2o,'Fioi_dust1',perrWith='quiet')

    index_x2o_Fogx_qicelo = mct_avect_indexra(x2o,'Fogx_qicelo')
    index_x2o_Fogx_qiceho = mct_avect_indexra(x2o,'Fogx_qiceho')
    index_x2o_Sg_blit    = mct_avect_indexra(x2o,'Sg_blit')
    index_x2o_Sg_blis    = mct_avect_indexra(x2o,'Sg_blis')
    index_x2o_Sg_lithop  = mct_avect_indexra(x2o,'Sg_lithop')
    index_x2o_Sg_icemask = mct_avect_indexra(x2o,'Sg_icemask')
    index_x2o_Sg_icemask = mct_avect_indexra(x2o,'Sg_icemask_grounded')
    index_x2o_Sg_icemask = mct_avect_indexra(x2o,'Sg_icemask_floating')

    if (wav_ocn_coup == 'twoway') then
       index_x2o_Sw_ustokes_wavenumber_1 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_1')
       index_x2o_Sw_vstokes_wavenumber_1 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_1')
       index_x2o_Sw_ustokes_wavenumber_2 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_2')
       index_x2o_Sw_vstokes_wavenumber_2 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_2')
       index_x2o_Sw_ustokes_wavenumber_3 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_3')
       index_x2o_Sw_vstokes_wavenumber_3 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_3')
       index_x2o_Sw_ustokes_wavenumber_4 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_4')
       index_x2o_Sw_vstokes_wavenumber_4 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_4')
       index_x2o_Sw_ustokes_wavenumber_5 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_5')
       index_x2o_Sw_vstokes_wavenumber_5 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_5')
       index_x2o_Sw_ustokes_wavenumber_6 = mct_avect_indexra(x2o,'Sw_ustokes_wavenumber_6')
       index_x2o_Sw_vstokes_wavenumber_6 = mct_avect_indexra(x2o,'Sw_vstokes_wavenumber_6')
       index_x2o_Sw_Hs = mct_avect_indexra(x2o,'Sw_Hs')
       index_x2o_Sw_Fp = mct_avect_indexra(x2o,'Sw_Fp')
       index_x2o_Sw_Dp = mct_avect_indexra(x2o,'Sw_Dp')
    endif
    call mct_aVect_clean(x2o)
    call mct_aVect_clean(o2x)

  end subroutine mpaso_cpl_indices_set

end module mpaso_cpl_indices
