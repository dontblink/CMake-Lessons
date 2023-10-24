# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-src"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-build"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/tmp"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/src/printf-populate-stamp"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/src"
  "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/src/printf-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/src/printf-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/mnt/c/code/EA/Cmake/libc-skeleton/buildresults/_deps/printf-subbuild/printf-populate-prefix/src/printf-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
