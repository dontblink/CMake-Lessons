cmake_minimum_required(VERSION 3.18)
project(EmbeddedArtistryLibc 
        VERSION 1.0 
        DESCRIPTION "A libc implementation for microcontroller-based embedded systems." 
        LANGUAGES C CXX ASM)

set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CPM.cmake)

# Only use testing if we're not somebody's subproject!
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR LIBC_BUILD_TESTING)
	include(CTest)
endif()

include(Packaging.cmake)
include(cmake/CheckAndApplyFlags.cmake)
include(BuildOptions.cmake)
include(cmake/Conversions.cmake)
include(cmake/AddExecutableWithLinkerScriptDep.cmake)
# Compiler Flags
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	add_compile_options(-Wall -Wextra)
endif()
if(ENABLE_COVERAGE)
  include(cmake/CodeCoverage.cmake)
  append_coverage_compiler_flags()
endif()

if(USE_SANITIZER MATCHES "([Aa]ddress)")
  add_compile_options(-fsanitize=address)
  add_link_options(-fsanitize=address)
elseif(USE_SANITIZER MATCHES "([Tt]hread)")
  add_compile_options(-fsanitize=thread)
  add_link_options(-fsanitize=thread)
elseif(USE_SANITIZER MATCHES "([Uu]ndefined)")
  add_compile_options(-fsanitize=undefined)
  add_link_options(-fsanitize=undefined)
elseif(USE_SANITIZER MATCHES "([Ll]eak)")
  add_compile_options(-fsanitize=leak)
  add_link_options(-fsanitize=leak)
elseif(USE_SANITIZER MATCHES "([Mm]emory)")
  add_compile_options(-fsanitize=memory)
  add_link_options(-fsanitize=memory)
elseif(USE_SANITIZER MATCHES "([Aa]ddress);([Uu]ndefined)")
  add_compile_options(-fsanitize=address,undefined)
  add_link_options(-fsanitize=address,undefined)
elseif(NOT "${USE_SANITIZER}" STREQUAL "")
  message(FATAL_ERROR "Unsupported value of USE_SANITIZER: ${USE_SANITIZER}")
endif()

# generate map file in linker
function(target_linker_map target)
  check_c_linker_flag("-Wl,-Map,test.map" _Map1)
  if("${_Map1}")
    set(GEN_MAP_FILE "-Wl,-Map,")
  else()
    check_c_linker_flag("-Wl,-map,test.map" _Map2)
    if("${_Map2}")
      set(GEN_MAP_FILE "-Wl,-map,")
    else()
      message("[WARNING] ${CMAKE_C_COMPILER_ID} does not have a defined linker map argument. ")
      return()
    endif()
  endif()
  get_target_property(map_dir ${target} BINARY_DIR)
  target_link_options(${target} PRIVATE ${GEN_MAP_FILE}${map_dir}/${target}.map)
  set_target_properties(${target} PROPERTIES
                        ADDITIONAL_CLEAN_FILES ${target}.map)
endfunction()




#####################
# add printf module #
#####################
CPMAddPackage(
  NAME printf
  GITHUB_REPOSITORY embeddedartistry/printf
  GIT_TAG 43e98e84
  DOWNLOAD_ONLY ON
)

add_library(printf INTERFACE)
target_sources(printf INTERFACE ${printf_SOURCE_DIR}/src/printf/printf.c)
# Both include paths are added so that `#include <printf.h>` and `#include <printf/printf.h>` will work
target_include_directories(printf SYSTEM INTERFACE ${printf_SOURCE_DIR}/src ${printf_SOURCE_DIR}/src/printf)
target_compile_definitions(printf INTERFACE PRINTF_ALIAS_STANDARD_FUNCTION_NAMES_HARD PRINTF_INCLUDE_CONFIG_H=0)

if(LIBC_TESTING_IS_ENABLED)
  add_executable(printf_tests)
  target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
  target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR}/src)
  set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)

  # Re-build + execute tests, printing test information to the console instead of the XML file
  add_custom_target(test-printf printf_tests)

  add_test(NAME Printf.Test
    COMMAND printf_tests -s -r junit -o ${CMAKE_BINARY_DIR}/printf_tests.xml
  )
  target_linker_map(printf_tests)
endif()


#######################
# add openlibm module #
#######################
CPMAddPackage(
              NAME openlibm
              GITHUB_REPOSITORY embeddedartistry/openlibm
              GIT_TAG 0418324
              DOWNLOAD_ONLY ON
              )
add_library(openlibm INTERFACE)
target_include_directories(openlibm SYSTEM INTERFACE
                           ${openlibm_SOURCE_DIR}/src
                           ${openlibm_SOURCE_DIR}/include)

##############
# add cmocka #
##############

if(LIBC_TESTING_IS_ENABLED)
  #Redefine add_custom_target so we can change cmocka's doc target name
  # in order to preserve our own
  function(add_custom_target target)
    if(${CMAKE_CURRENT_LIST_DIR} MATCHES cmocka-src AND ${target} STREQUAL docs)
      set(target cmocka-docs)
    endif()

    # Forward all arguments to the standard _add_custom_target
    _add_custom_target(${target} ${ARGN})
  endfunction()
  
  CPMFindPackage(
    NAME cmocka
    GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
    VERSION 1.1.7
    GIT_TAG cmocka-1.1.7
    OPTIONS
      "WITH_EXAMPLES OFF"
      "CMAKE_BUILD_TYPE DEBUG"
  )
endif()

#enable static analysis, don't need to run this on cmocka so set it after
find_program(CPPCHECK cppcheck)
if(CPPCHECK)
  set(CPPCHECK_DEFAULT_ARGS
      ${CPPCHECK} --quiet --enable=style --force
      # Include Directories
      -I ${CMAKE_CURRENT_LIST_DIR}/include)

  if(BUILD_WITH_STATIC_ANALYSIS)
    set(CMAKE_C_CPPCHECK ${CPPCHECK_DEFAULT_ARGS})
  endif()

  add_custom_target(cppcheck
                    COMMAND ${CPPCHECK_DEFAULT_ARGS}
                    # Source directories
                    ${CMAKE_CURRENT_LIST_DIR}/src ${CMAKE_CURRENT_LIST_DIR}/target/)

  add_custom_target(cppcheck-xml
                    COMMAND ${CPPCHECK_DEFAULT_ARGS}
                    #enable XML output
                    --xml --xml-version=2
                    $ Source Directories
                    ${CMAKE_CURRENT_LIST_DIR}/src/ ${CMAKE_CURRENT_LIST_DIR}/target/
                    # Redirect to file
                    2>${CMAKE_BINARY_DIR}/cppcheck.xml
                    )
endif()

find_program(CLANG_TIDY clang-tidy)
if(CLANG_TIDY)
  if(BUILD_WITH_STATIC_ANALYSIS)
    set(CMAKE_C_CLANG_TIDY ${CLANG_TIDY})
  endif()
  add_custom_target(tidy
                    COMMAND tools/clang-tidy.sh ${CMAKE_BINARY_DIR}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif()

#process source tree
add_subdirectory(arch/${CMAKE_SYSTEM_PROCESSOR}/)
add_subdirectory(src)

#process test tree

add_subdirectory(test)
if(ENABLE_COVERAGE)
  setup_target_for_coverage_gcovr_xml(
                                      NAME coverage-xml
                                      EXECUTABLE ctest
                                      DEPENDENCIES libc_tests printf_tests
                                      )

  setup_target_for_coverage_gcovr_html(
                                       NAME coverage-html
                                       EXECUTABLE ctest
                                       DEPENDENCIES libc_tests printf_tests
                                       )

  add_custom_target(coverage 
                    DEPENDS coverage-xml coverage-html)
endif()

find_program(DOXYGEN doxygen)

if(DOXYGEN)
  add_custom_target(docs
                    COMMAND ${DOXYGEN} docs/Doxyfile
                    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                    )
  #this property will remove a directory, while add_custom_target BYPRODUCTS will not
  set_target_properties(docs PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_BINARY_DIR}/doc/)
endif()

find_program(CLANG_FORMAT clang-format)
if(CLANG_FORMAT)
  add_custom_target(format
                    COMMAND tools/format.sh
                    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
                    )
  add_custom_target(format-patch
                    COMMAND tools/format-patch.sh
                    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
endif()

find_program(LIZARD lizard)
if(LIZARD)
  set(LIZARD_BASE_ARGS
      ${LIZARD}
      # Configuration
      --length 75 #fail when functions longer than this
      --CCN 10 # fail over this ccn
      --arguments 10 # fail this arg count
      )
  set(LIZARD_PATHS ${CMAKE_CURRENT_LIST_DIR}/src ${CMAKE_CURRENT_LIST_DIR}/tests)
  
  add_custom_target(complexity
                    COMMAND
                    ${LIZARD_BASE_ARGS}
                    -w # Only show warnings
                    ${LIZARD_PATHS}
                    )

  add_custom_target(complexity-full
  COMMAND
    ${LIZARD_BASE_ARGS}
    ${LIZARD_PATHS}
)

  add_custom_target(complexity-xml
  COMMAND
    ${LIZARD_BASE_ARGS}
    --xml # Generate XML output
    ${LIZARD_PATHS}
    # Redirect output to file
    > ${CMAKE_BINARY_DIR}/complexity.xml
  BYPRODUCTS
    ${CMAKE_BINARY_DIR}/complexity.xml
)
endif()

if(ENABLE_COVERAGE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
endif()

install(FILES ${printf_SOURCE_DIR}/src/printf/printf.h DESTINATION include)
install(DIRECTORY ${openlibm_SOURCE_DIR}/include/ DESTINATION include)
install(DIRECTORY ${openlibm_SOURCE_DIR}/src DESTINATION include FILES_MATCHING PATTERN "*.h")
