if ("${SCREAM_DYNAMICS_DYCORE}" STREQUAL "HOMME")
  add_subdirectory(homme)
endif()
add_subdirectory(p3)
add_subdirectory(shoc)
add_subdirectory(cld_fraction)
add_subdirectory(spa)
add_subdirectory(surface_coupling)
if (SCREAM_ENABLE_ML_CORRECTION )
  add_subdirectory(ml_correction)
endif()
if (SCREAM_DOUBLE_PRECISION)
  add_subdirectory(rrtmgp)
  add_subdirectory(cosp)
else()
  message(STATUS "RRTMGP and COSP only supported for double precision builds; skipping")
endif()
if (SCREAM_ENABLE_MAM)
  add_subdirectory(mam/optics)
  add_subdirectory(mam/aci)
  add_subdirectory(mam/drydep)
  add_subdirectory(mam/emissions)
  add_subdirectory(mam/constituent_fluxes)
  add_subdirectory(mam/wet_scav)
  add_subdirectory(mam/aero_microphys)
endif()
if (SCREAM_TEST_LEVEL GREATER_EQUAL SCREAM_TEST_LEVEL_EXPERIMENTAL)
  add_subdirectory(zm)
endif()
