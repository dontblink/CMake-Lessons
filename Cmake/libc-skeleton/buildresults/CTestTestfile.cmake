# CMake generated Testfile for 
# Source directory: /mnt/d/code/EA/Cmake/libc-skeleton
# Build directory: /mnt/d/code/EA/Cmake/libc-skeleton/buildresults
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(Printf.Test "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/printf_tests" "-s" "-r" "junit" "-o" "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/printf_tests.xml")
set_tests_properties(Printf.Test PROPERTIES  _BACKTRACE_TRIPLES "/mnt/d/code/EA/Cmake/libc-skeleton/CMakeLists.txt;93;add_test;/mnt/d/code/EA/Cmake/libc-skeleton/CMakeLists.txt;0;")
subdirs("src")
subdirs("test")
