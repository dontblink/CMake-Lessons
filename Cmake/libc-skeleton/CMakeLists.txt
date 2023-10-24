cmake_minimum_required(VERSION 3.18)
project(EmbeddedArtistryLibc 
        VERSION 1.0 
        DESCRIPTION "A libc implementation for microcontroller-based embedded systems." 
        LANGUAGES C CXX)

set_property(GLOBAL PROPERTY C_STANDARD 11)

include(cmake/CPM.cmake)
include(cmake/CheckAndApplyFlags.cmake)
include(BuildOptions.cmake)

# Only use testing if we're not somebody's subproject!
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME OR LIBC_BUILD_TESTING)
	include(CTest)
endif()

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
	add_compile_options(-Wall -Wextra)
endif()



#####################
# add printf module #
#####################
CPMAddPackage(
              NAME printf
              GITHUB_REPOSITORY mpaland/printf
              VERSION 4.0.0
              DOWNLOAD_ONLY
              )
# add printf as an interface library as it doesn't use cmake, 
# so we need to manually make build targets
add_library(printf INTERFACE)
target_sources(printf INTERFACE ${printf_SOURCE_DIR}/printf.c)
#use SYSTEM here so that the external dependency headers won't generate warnings in our build
target_include_directories(printf SYSTEM INTERFACE ${printf_SOURCE_DIR})

if(LIBC_TESTING_IS_ENABLED)
	add_executable(printf_tests)
	target_sources(printf_tests PRIVATE ${printf_SOURCE_DIR}/test/test_suite.cpp)
	target_include_directories(printf_tests PRIVATE ${printf_SOURCE_DIR})
	set_target_properties(printf_tests PROPERTIES CXX_STANDARD 11)
	add_test(NAME Printf.Test 
	         COMMAND printf_tests -s -r junit -o ${CMAKE_BINARY_DIR}/printf_tests.xml)

	#rebuild + execute tests, print info to console instead of xml
	add_custom_target(test-printf printf_tests)
endif()



#######################
# add openlibm module #
#######################
CPMAddPackage(
              NAME openlibm
              GITHUB_REPOSITORY JuliaMath/openlibm
              VERSION 0.7.0
              DOWNLOAD_ONLY
              )
add_library(openlibm INTERFACE)
target_include_directories(openlibm SYSTEM INTERFACE
                           ${openlibm_SOURCE_DIR}/src
                           ${openlibm_SOURCE_DIR}/include)

##############
# add cmocka #
##############
#since cmocka is built with cmake, we can just use find_package
#we manually installed cmocka, so should be able to find this

if(LIBC_TESTING_IS_ENABLED)
	find_package(cmocka QUIET)

	#as a fallback, if we don't have it installed we can download and install using CPMAddPackage
	if(NOT cmocka_FOUND)
		include(ExternalProject)
		CPMAddPackage(
		              NAME cmocka
		              GIT_REPOSITORY https://git.cryptomilk.org/projects/cmocka.git/
		              VERSION 1.1.5
		              GIT_TAG cmocka-1.1.5
		              OPTIONS
		              "WITH_EXAMPLES OFF"
		              "CMAKE_BUILD_TYPE DEBUG"
		              DOWNLOAD_ONLY YES
		              )
		# Maintain build compatibility between find_package and CMakeLists.txt variants
		set(CMOCKA_STATIC_FILENAME
		    ${CMAKE_STATIC_LIBRARY_PREFIX}cmocka-static${CMAKE_STATIC_LIBRARY_SUFFIX})

		ExternalProject_Add(project_cmocka
	        SOURCE_DIR ${cmocka_SOURCE_DIR}
	        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/cmocka
	        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/cmocka
	        CMAKE_ARGS
	        	-DBUILD_STATIC_LIB=ON
	        	-DWITH_STATIC_LIB=ON #Without this, Cmocka will not install the static lib)
	        	-DWITH_EXAMPLE=OFF
	        	-DCMAKE_BUILD_TYPE=Debug
	        	-DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/cmocka
	        	#this is needed with Ninja generators to prevent it from failing due to the library
	        	#being missing before the build has run
	    	BUILD_BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/cmocka/lib/${CMOCKA_STATIC_FILENAME}
	    	)

		# figure out where our built libraries can be found
		ExternalProject_Get_Property(project_cmocka BINARY_DIR)

		add_library(cmocka-static IMPORTED STATIC)
		set_target_properties(cmocka-static PROPERTIES
	        IMPORTED_LOCATION ${BINARY_DIR}/lib/${CMOCKA_STATIC_FILENAME})
		
		# ensures our target will be built in the correct order
		# and will be available at link time
		add_dependencies(cmocka-static project_cmocka)

		#ensure compatability between find_package and ExternalProject
		set(CMOCKA_LIBRARIES cmocka-static)
		set(CMOCKA_INCLUDE_DIR ${BINARY_DIR}/include)

	endif()	
endif()

add_subdirectory(src)
if(LIBC_TESTING_IS_ENABLED)
	add_subdirectory(test)
endif()

