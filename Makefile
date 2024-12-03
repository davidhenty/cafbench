PROJECT=cafbench
VERSION=1.1

MF=	Makefile

# Settings for the Cray ftn compiler

FC=	ftn
FFLAGS=	-h caf -e F
LDFLAGS=
LIBS=
FDEFS=	-DMPI

# Settings for the Intel Fortran compiler

#FC=	ifort
#FFLAGS=	-fpp -coarray=distributed -coarray-config-file=cafbench.config
#LDFLAGS=
#LIBS=
#FDEFS=

# Settings for g95 (locks not supported so comment them out in cafsync.f90)

#FC=	g95
#FFLAGS=	-cpp
#LDFLAGS=
#LIBS=
#FDEFS=	-UMPI


# Should be no need to alter anything below here

CAFSRC=\
	cafbench.f90 \
	cafpt2pt.f90 \
	cafpt2ptdriver.f90 \
	cafsync.f90 \
	cafsyncdriver.f90 \
	cafhalo.f90 \
	cafhalodriver.f90 \
	cafcore.f90 \
	cafclock.f90 \
	cafparams.f90

CAFEXE=	$(PROJECT)

CAFVER=	$(PROJECT)-$(VERSION)
CAFTAR=	$(CAFVER).tar

.SUFFIXES:
.SUFFIXES: .f90 .o

.f90.o:
	$(FC) $(FDEFS) $(FFLAGS) -c $< 

CAFOBJ=$(CAFSRC:.f90=.o)

all:	$(CAFEXE)

$(CAFEXE): $(CAFOBJ)
	$(FC) -o $@ $(FDEFS) $(FFLAGS) $(CAFOBJ) $(LDFLAGS) $(LIBS)

$(CAFOBJ): $(MF)


cafbench.o:		cafpt2ptdriver.o cafsyncdriver.o cafhalodriver.o

cafpt2ptdriver.o:	cafpt2pt.o cafcore.o cafparams.o
cafsyncdriver.o:	cafsync.o  cafcore.o cafparams.o
cafhalodriver.o:	cafhalo.o  cafcore.o cafparams.o

cafpt2pt.o:	cafcore.o cafclock.o cafparams.o
cafhalo.o:	cafcore.o cafclock.o cafparams.o
cafsync.o:	cafcore.o cafclock.o

cafcore.o:	cafclock.o

clean:
	rm -f $(CAFEXE) $(CAFOBJ)

tar:
	if [ -d $(CAFVER) ]; \
	  then echo "Error: directory $(CAFVER) already exists"; \
	else \
		mkdir $(CAFVER); \
	 	cp LICENSE.txt README.txt $(MF) $(CAFSRC) $(CAFVER); \
		tar cvf $(CAFTAR) $(CAFVER); \
		rm -rf $(CAFVER); \
	fi
