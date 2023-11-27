add_executable(MYPROJECT_tests)
target_include_directories(MYPROJECT_tests PRIVATE . )
target_link_libraries(MYPROJECT_tests PRIVATE cmocka::cmocka)
target_sources(MYPROJECT_tests PRIVATE
               main.c
               test_suite.c)
target_linker_map(MYPROJECT_tests)

list(APPEND desired_MYPROJECT_test_flags
     "-Wno-unused-parameter")
apply_supported_compiler_flags(C MYPROJECT_tests PRIVATE desired_MYPROJECT_test_flags)

function(register_cmocka_test test_name target)
     add_custom_target(test-${target}
                       COMMAND export CMOCKA_MESSAGE_OUTPUT=stdout
                       COMMAND ${target}
                       )

     # Register Tests with CTest


     add_test(NAME ${test_name}
              COMMAND ${target}
              )
     set_tests_properties(${test_name}
                          PROPERTIES
                          	ENVIRONMENT CMOCKA_XML_FILE=${CMOCKA_TEST_OUTPUT_DIR}/%g.xml
                          	DEPENDS CMocka.ClearResults)
endfunction()


register_cmocka_test(MYPROJECT.Test MYPROJECT_tests)
