#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/profile.d/modules.sh
module add ci
module add  gcc/6.3.0
cd ${WORKSPACE}/${NAME}-${VERSION}
./camb test_params.ini

echo $?
mkdir -p $SOFT_DIR/bin $SOFT_DIR/lib
cp camb $SOFT_DIR/bin
cp Releaselib/*.so $SOFT_DIR/lib
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       COSMOMC_CAMB_VERSION       $VERSION
setenv       COSMOMC_CAMB_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(COSMOMC_CAMB_DIR)/lib
prepend-path CFLAGS            "$CFLAGS -I$::env(COSMOMC_CAMB_DIR)/include"
prepend-path LDFLAGS           "$LDFLAGS -L$::env(COSMOMC_CAMB_DIR)/lib"
MODULE_FILE
) > modules/$VERSION

mkdir -vp ${ASTRONOMY}/${NAME}
cp -v modules/$VERSION ${ASTRONOMY}/${NAME}
module avail ${NAME}
module add  ${NAME}/${VERSION}
