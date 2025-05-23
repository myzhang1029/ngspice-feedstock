#!/bin/bash

set -x
set -e

# Used by autotools AX_PROG_CC_FOR_BUILD
export CC_FOR_BUILD=${CC}

./autogen.sh
cp "$(dirname "$(which autoconf)")/../share/autoconf/build-aux/config.guess" .
cp "$(dirname "$(which autoconf)")/../share/autoconf/build-aux/config.sub" .

configure_args=(
  --prefix=${PREFIX}
  --enable-xspice
  --disable-debug
  --disable-dependency-tracking
  --enable-cider
  --with-readline=no
  --enable-openmp

  # Not enabled for now:
  #  --enable-adms
)

export LDFLAGS="${LDFLAGS} -m64"
export CXXFLAGS="${CXXFLAGS} -w -std=gnu++11 -Wno-invalid-specialization -Wno-implicit-function-declaration"
export CFLAGS="${CFLAGS} -w -std=gnu11 -Wno-invalid-specialization -Wno-implicit-function-declaration"

if [[ ! -z "${BUILD_NGSPICE_LIB}" && ! -z "${BUILD_NGSPICE_EXE}" ]]; then
  2>&1 echo "Set either BUILD_NGSPICE_LIB or BUILD_NGSPICE_EXE"
  exit 1
fi

if [[ ! -z "${BUILD_NGSPICE_LIB}" ]]; then
  #
  # build libngspice.dylib
  #
  mkdir release-lib && cd release-lib
  ../configure "${configure_args[@]}" --with-ngshared LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
  make -j${CPU_COUNT}
  make install
  cd -
fi

if [[ ! -z "${BUILD_NGSPICE_EXE}" ]]; then
  #
  # build ngspice executable
  #
  mkdir release-bin && cd release-bin
  ../configure "${configure_args[@]}" --with-x LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
  make -j${CPU_COUNT}
  make install
  cd -
fi
