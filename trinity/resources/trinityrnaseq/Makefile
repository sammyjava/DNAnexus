###################################################################
#
# The default compiler is GNU gcc/g++.
# Run
#  make TRINITY_COMPILER=intel
# to build Inchworm and Chrysalis with the Intel compiler.
#

ifeq ($(TRINITY_COMPILER),intel)
 INCHWORM_CONFIGURE_FLAGS = CXX=icpc CXXFLAGS="-fast"
 CHRYSALIS_MAKE_FLAGS = COMPILER=icpc
else
 override TRINITY_COMPILER=gnu
endif


all: inchworm_target chrysalis_target trinity_essentials
	sh ./util/support_scripts/trinity_install_tests.sh

inchworm_target:
	@echo Using $(TRINITY_COMPILER) compiler for Inchworm and Chrysalis
	cd Inchworm && (test -e configure || autoreconf) \
                && sh ./configure --prefix=`pwd` $(INCHWORM_CONFIGURE_FLAGS) && $(MAKE) install

chrysalis_target:
	cd Chrysalis && $(MAKE) UNSUPPORTED=yes $(CHRYSALIS_MAKE_FLAGS)


trinity_essentials:
	cd trinity-plugins && $(MAKE) trinity_essentials


plugins:
	cd trinity-plugins && $(MAKE) plugins
	sh ./util/support_scripts/plugin_install_tests.sh

test:
	@echo
	@echo "Checking for Trinity essentials (built from 'make all'):"
	sh ./util/support_scripts/trinity_install_tests.sh
	@echo
	@echo "Checking for plugins (built from 'make plugins'):"
	sh ./util/support_scripts/plugin_install_tests.sh
	@echo "Run 'make test_trinity' if you want to test Trinity execution on a small data set"

clean:
	cd Inchworm && make clean
	cd Chrysalis && $(MAKE) clean UNSUPPORTED=yes
	cd trinity-plugins && $(MAKE) clean 
	cd sample_data/ && make clean


test_trinity:
	cd sample_data/test_Trinity_Assembly && make test

test_gg_trinity:
	cd sample_data/test_GenomeGuidedTrinity && make test



# note 'test_all': ** this is for a more advanced installation including devel features **

test_all:
	cd sample_data/ && make test_all

test_clean:
	cd sample_data/ && make clean

###################################################################


