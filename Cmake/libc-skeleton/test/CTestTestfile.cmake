# CMake generated Testfile for 
# Source directory: /mnt/c/code/EA/Cmake/libc-skeleton/test
# Build directory: /mnt/c/code/EA/Cmake/libc-skeleton/test
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(Libc.ClearResults "/usr/bin/cmake" "--build" "/mnt/c/code/EA/Cmake/libc-skeleton" "--target" "test-clear-results")
set_tests_properties(Libc.ClearResults PROPERTIES  _BACKTRACE_TRIPLES "/mnt/c/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;96;add_test;/mnt/c/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;0;")
add_test(Libc.Test "/mnt/c/code/EA/Cmake/libc-skeleton/test/libc_tests")
set_tests_properties(Libc.Test PROPERTIES  DEPENDS "Libc.ClearResults" ENVIRONMENT "CMOCKA_XML_FILE=/mnt/c/code/EA/Cmake/libc-skeleton/test/%g.xml" _BACKTRACE_TRIPLES "/mnt/c/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;98;add_test;/mnt/c/code/EA/Cmake/libc-skeleton/test/CMakeLists.txt;0;")
