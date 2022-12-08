#!/bin/bash -e

set -e
set -o pipefail

function set_version_vars {
  export RN_VERSION=`jq -r .version package.json`
  export RN_VERSION_U=`echo $RN_VERSION | tr . _`
  export RN_VERSION_MAJOR=`echo $RN_VERSION | cut -d. -f1`
  export RN_VERSION_MINOR=`echo $RN_VERSION | cut -d. -f2`
  export RN_VERSION_PATCH=`echo $RN_VERSION | cut -d. -f3`
}

export NUM_PROCESSORS=$( getconf _NPROCESSORS_ONLN )

# Note that CMakeLists.txt assumes that all the resources are in /shared.
# Therefore, it is recommend to link the dir with all the resources to /shared
export SOURCE_DIR=/shared
BUILD_DIR=/root/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/stage

set_version_vars

export RN_ABI=x86_64
export RN_ABI_U=x86_64
export RN_TARGET=centos7
export RN_PLATFORM=el7.centos
export RN_PLATFORM_U=el7_centos
export RN_TOOLCHAIN=gcc
sed -i "s/.el7/.el7.centos/g" /etc/rpm/macros.dist

cd ${BUILD_DIR}

INSTALL_DIR=${PWD}/stage

export PATH=$INSTALL_DIR/bin:/opt/local/bin:$PATH
export C_INCLUDE_PATH=$INSTALL_DIR/include
export CPLUS_INCLUDE_PATH=$INSTALL_DIR/include
export LIBRARY_PATH=$INSTALL_DIR/lib:/opt/local/lib64
export PKG_CONFIG_PATH=/opt/local/lib64/pkgconfig:/opt/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=/opt/local/lib64:/opt/local/lib:/usr/local/lib64:/usr/local/lib


cmake -DCMAKE_INSTALL_PREFIX:PATH=${INSTALL_DIR}       -DCMAKE_BUILD_TYPE:STRING=RELEASE       -DCPACK_PACKAGE_VERSION=${RN_VERSION}       -DCPACK_GENERATOR=RPM       -DRPM_INSTALL_DIR=/opt/local      ${SOURCE_DIR}/.


make package

for RPM in *.rpm; do
  cp $RPM ${SOURCE_DIR}/$(rpm -qp $RPM).rpm
done
