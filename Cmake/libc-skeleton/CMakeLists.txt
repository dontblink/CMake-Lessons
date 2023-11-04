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

include(cmake/CheckAndApplyFlags.cmake)
include(BuildOptions.cmake)
include(cmake/Conversions.cmake)
include(cmake/AddExecutableWithLinkerScriptDep.cmake)
# Compiler Flags
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	add_compile_options(-Wall -Wextra)
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

#process source tree
add_subdirectory(arch/${CMAKE_SYSTEM_PROCESSOR}/)
add_subdirectory(src)

#process test tree

add_subdirectory(test)

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
