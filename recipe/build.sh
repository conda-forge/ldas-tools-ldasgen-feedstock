#!/bin/bash

mkdir -p _build
pushd _build

# link librt to get clock_gettime on older glibc versions
if [ "$(uname)" == "Linux" ]; then
	export LDFLAGS="-lrt ${LDFLAGS}"
fi

# configure
cmake \
	${SRC_DIR} \
	${CMAKE_ARGS} \
	-DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
	-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=true \
	-DCMAKE_OSX_ARCHITECTURES:STRING="${OSX_ARCH}" \
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
