# CMake generated Testfile for 
# Source directory: /mnt/d/code/EA/Cmake/libc-skeleton/test
# Build directory: /mnt/d/code/EA/Cmake/libc-skeleton/buildresults/test
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(LibC.Test "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/test/libc_tests")
set_tests_properties(LibC.Test PROPERTIES  DEPENDS "Libc.ClearResults" ENVIRONMENT "CMOCKA_XML_FILE=/mnt/d/code/EA/Cmake/libc-skeleton/buildresults/test/%g.xml" _BACKTRACE_TRIPLES "/mnt/d/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;93;add_test;/mnt/d/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;0;")
add_test(Libc.ClearResults "/usr/local/bin/cmake" "--build" "/mnt/d/code/EA/Cmake/libc-skeleton/buildresults" "--target" "test-clear-results")
set_tests_properties(Libc.ClearResults PROPERTIES  _BACKTRACE_TRIPLES "/mnt/d/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;95;add_test;/mnt/d/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;0;")
