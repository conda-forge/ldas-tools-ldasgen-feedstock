#!/bin/bash

set -ex

mkdir -p _build
pushd _build

# configure
cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=true \
  -DCMAKE_OSX_ARCHITECTURES:STRING="${OSX_ARCH}" \
  -DCMAKE_POLICY_VERSION_MINIMUM:STRING=3.5 \
  ${SRC_DIR}

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --verbose
fi

# install
cmake --build . --parallel ${CPU_COUNT} --verbose --target install
