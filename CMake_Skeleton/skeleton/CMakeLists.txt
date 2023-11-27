cmake_minimum_required(VERSION 3.17)

project(MYPROJECT
	VERSION 0.1
	DESCRIPTION "MYDESCRIPTION"
	LANGUAGES C CXX ASM)

set_property(GLOBAL PROPERTY C_STANDARD 11)
set_property(GLOBAL PROPERTY CXX_STANDARD 17)

include(cmake/CPM.cmake)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR PROJECTVARNAME_BUILD_TESTING)
    include(CTest)
endif()

include(Packaging.cmake)
include(cmake/compiler/CheckAndApplyFlags.cmake)
include(BuildOptions.cmake)
include(cmake/Conversions.cmake)
include(cmake/linker/AddExecutableWithLinkerScriptDep.cmake)
include(cmake/linker/map.cmake)
include(cmake/analysis/sanitizers.cmake)
include(cmake/documentation/doxygen.cmake)

set(CLANG_FORMAT_ADDITIONAL_FILETYPES *.tpp)
# Provides clang-format build targets
include(cmake/format/clang-format.cmake)
##################
# Compiler Flags #
##################

include(cmake/compiler/DefaultCompilerSettings.cmake)
include(cmake/linker/DefaultLinkerSettings.cmake)


# Enable code coverage analysis support target
include(cmake/analysis/coverage.cmake)
enable_coverage_targets(MYPROJECT_tests)

#####################
# CMocka Dependency #
#####################

if(PROJECTVARNAME_TESTING_IS_ENABLED)
  include(cmake/test/cmocka.cmake)
endif()

##########################
# Enable Static Analysis #
##########################



set(CLANG_TIDY_ADDITIONAL_OPTIONS --fix)
#Provides clang-tidy targets and options to compile with clang-tidy analysis
include(cmake/analysis/clang-tidy.cmake)
#######################
# Process Source Tree #
#######################

#add_subdirectory(src)

#####################
# Process Test Tree #
#####################

add_subdirectory(test)

###################
# Tooling Targets #
###################




include(cmake/analysis/complexity.cmake)
