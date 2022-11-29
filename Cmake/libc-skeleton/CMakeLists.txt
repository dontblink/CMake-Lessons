cmake_minimum_required(VERSION 3.17)
project( EmbeddedArtistryLibc
        VERSION 1.0
        DESCRIPTION "A libc implementation for microcontroller-based embedded systems."
        LANGUAGES C CXX)
set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CheckAndApplyFlags.cmake)

set(default_pic ON)
if("${CMAKE_POSITION_INDEPENDENT_CODE}" STREQUAL "")
        message(STATUS "Setting PIC for all targets to '${default_pic}' as no value was specified.")
        set(CMAKE_POSITION_INDEPENDENT_CODE ${default_pic} CACHE
            BOOL "Compile all targets with -fPIC"
            FORCE)
endif()

set(default_shared_libs OFF)
if("${BUILD_SHARED_LIBS}" STREQUAL "")
        message(STATUS "Setting 'build shared libraries' to '${default_shared_libs}' as no value was specified")
        set(BUILD_SHARED_LIBS ${default_shared_libs} CACHE
            BOOL "Compile shared libraries by default instead of static libraries."
            FORCE
)
endif()

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
        add_compile_options(-Wall -Wextra)
endif()

# Export compile_commands.json file
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)        

include(cmake/CPM.cmake)

CPMAddPackage(
        	NAME printf
        	GITHUB_REPOSITORY mpaland/printf
        	VERSION 4.0.0
        	DOWNLOAD_ONLY #this library doesn't use cmake, don't configure the project
)
add_library(printf INTERFACE)
target_sources(printf INTERFACE  ${printf_SOURCE_DIR}/printf.c)
target_include_directories(printf SYSTEM INTERFACE ${printf_SOURCE_DIR})

CPMAddPackage(
            NAME openlibm
            GITHUB_REPOSITORY JuliaMath/openlibm
            VERSION 0.7.0
            DOWNLOAD_ONLY
)
add_library(openlibm INTERFACE)
target_include_directories(openlibm SYSTEM INTERFACE 
                           ${openlibm_SOURCE_DIR}/src
                           ${openlibm_SOURCE_DIR}/include
)

add_subdirectory(src)

#we installed cmocka in our system, so should be able to find it
#otherwise use CPM to install it
find_package(cmocka QUIET)

if(NOT cmocka_FOUND)
	CPMAddPackage(
              NAME cmocka
              GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
              VERSION 1.1.5
              GIT_TAG cmocka-1.1.5
              OPTIONS
              	"WITH_EXAMPLES OFF"
              	"CMAKE_BUILD_TYPE DEBUG"

  	#maintain build compatibility between find_package and CMakeLists.txt variants
  	set(CMOCKA_LIBRARIES cmocka)
)
endif()


#Only use testing if we're not somebody's subproject
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	include(CTest)
endif()

if(BUILD_TESTING)

 	add_subdirectory(test)
	
        add_executable(printf_tests)
	target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
	target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR})
	set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)
	add_test(NAME Printf.Test 
	         COMMAND printf_tests -s -r junit -o ${CMAKE_BINARY_DIR}/printf_tests.xml)
        add_custom_target(test-printf printf_tests)
endif()
