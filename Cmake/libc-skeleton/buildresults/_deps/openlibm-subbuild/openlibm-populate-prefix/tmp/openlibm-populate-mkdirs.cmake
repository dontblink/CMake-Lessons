# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-src"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-build"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/tmp"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/src/openlibm-populate-stamp"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/src"
  "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/src/openlibm-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/src/openlibm-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/_deps/openlibm-subbuild/openlibm-populate-prefix/src/openlibm-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
