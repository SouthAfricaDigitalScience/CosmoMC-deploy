#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
module add  gcc/6.3.0
cd ${WORKSPACE}/${NAME}-${VERSION}

echo "All tests have passed, will now build into ${SOFT_DIR}"
make all
mkdir -p $SOFT_DIR/bin $SOFT_DIR/lib
cp camb $SOFT_DIR/bin
cp Releaselib/*.so $SOFT_DIR/lib


echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/COSMOMC_CAMB-deploy"
setenv COSMOMC_CAMB_VERSION       $VERSION
setenv COSMOMC_CAMB_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(COSMOMC_CAMB_DIR)/lib
prepend-path CFLAGS            "$CFLAGS -I$::env(COSMOMC_CAMB_DIR)/include"
prepend-path LDFLAGS           "$LDFLAGS -L$::env(COSMOMC_CAMB_DIR)/lib"
MODULE_FILE
) > ${ASTRONOMY}/${NAME}/${VERSION}

module avail ${NAME}

module add  ${NAME}/${VERSION}
