#!/bin/bash

MESON_BUILD_ROOT=${MESON_BUILD_ROOT:-./buildresults}

# remove pipe command from compile_commands.json. seems to only affect osx
cd "${MESON_BUILD_ROOT}"
sed -i.bak 's/-pipe//g' compile_commands.json

clang-tidy -quiet -p ${MESON_BUILD_ROOT} $@
