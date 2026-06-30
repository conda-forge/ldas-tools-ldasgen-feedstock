#!/bin/bash

mkdir -p _build
pushd _build

# configure
cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=true \
  -DCMAKE_OSX_ARCHITECTURES:STRING="${OSX_ARCH}" \
  ${SRC_DIR} \
;

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --verbose || {
  if [ "$(uname)" == "Linux" ]; then
    # see https://git.ligo.org/ldastools/LDAS_Tools/-/issues/124
    echo "WARNING: ctest failed";
  else
    exit 1;
  fi;
  }
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
