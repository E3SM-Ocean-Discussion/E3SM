.SUFFIXES: .F .o .F90

OBJS = mpas_ocn_forward_mode.o \
       mpas_ocn_time_integration.o \
       mpas_ocn_time_integration_rk4.o \
       mpas_ocn_time_integration_si.o \
       mpas_ocn_time_integration_split.o

all: forward_mode

forward_mode: $(OBJS) 

mpas_ocn_time_integration.o: mpas_ocn_time_integration_rk4.o mpas_ocn_time_integration_si.o  mpas_ocn_time_integration_split.o

mpas_ocn_time_integration_rk4.o: 

mpas_ocn_time_integration_si.o: 

mpas_ocn_time_integration_split.o: 

mpas_ocn_forward_mode.o: mpas_ocn_time_integration.o \
                         mpas_ocn_time_integration_rk4.o \
                         mpas_ocn_time_integration_si.o \
                         mpas_ocn_time_integration_split.o \
                         $(SMARTREDIS_PATH)/../src/fortran/fortran_c_interop.F90 \
                         $(SMARTREDIS_PATH)/../src/fortran/dataset.F90 \
                         $(SMARTREDIS_PATH)/../src/fortran/client.F90
clean:
	$(RM) *.o *.mod *.f90

.F.o:
	$(RM) $@ $*.mod
ifeq "$(GEN_F90)" "true"
	$(CPP) $(CPPFLAGS) $(CPPINCLUDES) $< > $*.f90
	$(FC) $(FFLAGS) -c $*.f90 $(FCINCLUDES)
else
	$(FC) $(CPPFLAGS) $(FFLAGS) -c $*.F $(CPPINCLUDES) $(FCINCLUDES)
endif
