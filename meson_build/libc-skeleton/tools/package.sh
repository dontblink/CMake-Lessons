#!/bin/bash

while getopts "na:c:s:v:" opt; do
	case $opt in
		a) ARCH="$OPTARG"
		;;
		c) CHIP="$OPTARG"
		;;
		s) SYSTEM="$OPTARG"
		;;
		n) NATIVE='1'
		;;
		v) VERSION="$OPTARG"
		;;
		\?) echo "Invalid option -$OPTARG" >&2
		;;
	esac
done

# construct file name from arch/chip/system/version
FILENAME=libc
if [ "$NATIVE" == '1' ]; then
	FILENAME+='_native'
fi

FILENAME+=_${ARCH}-${CHIP}-${SYSTEM}

if [ "$VERSION" != '' ]; then
	FILENAME+=_${VERSION}
fi

FILENAME+=.tgz

# create folder to contain the releases
RELEASE_DIR=${MESON_BUILD_ROOT}/releases
mkdir -p "${RELEASE_DIR}"

# select proper library file based on the -n option
if [ "$NATIVE" == '1' ]; then
	LIB_FILE="libc_native.a"
else
	LIB_FILE="libc.a"
fi

# copy the files into the archive
# Frist, we add the includese
cd ${MESON_SOURCE_ROOT}
tar -cf ${RELEASE_DIR}/${FILENAME} include/ arch/${ARCH}/include

# Next we add documentation
cd ${MESON_BUILD_ROOT}
tar -uf ${RELEASE_DIR}/${FILENAME} docs

# Finally we add the library file(s)
cd ${MESON_BUILD_ROOT}/src
tar -uf ${RELEASE_DIR}/${FILENAME} ${LIB_FILE}
