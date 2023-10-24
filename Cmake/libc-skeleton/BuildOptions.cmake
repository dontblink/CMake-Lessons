include(CMakeDependentOption)

option(HIDE_UNIMPLEMENTED_C_APIS
       "Make unimplemented libc functions invisible to the compiler."
       OFF)

option(ENABLE_GNU_EXTENSIONS
       "Enable GNU extensions to the standard libc functions"
       OFF)

option(DISABLE_BUILTINS
       "Disable builts to the library target but not it's dependencies"
       ON)

option(DISABLE_STACK_PROTECTION
       "Disable stack protection on libc target and its dependencies"
       ON)

option(NOSTDINC_FOR_DEPENDENTS
       "apply_supported_compiler_flags for -nostdinc should use a public scope when on, private when off"
       OFF)

CMAKE_DEPENDENT_OPTION(LIBC_BUILD_TESTING
       "enables unit test builds when this project is used as a dependency in another project"
       OFF
       "NOT CMAKE_CROSSCOMPILING" OFF)

if((NOT CMAKE_CROSSCOMPILING) AND BUILD_TESTING AND 
   (LIBC_BUILD_TESTING OR (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)))
	message("Enabling libc tests.")
	set(LIBC_TESTING_IS_ENABLED ON CACHE INTERNAL "Logic that sets whether testing is enabled on this project")
endif()

#Set a default build type if none was specified
set(default_build_type "RelWithDebInfo")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFICATION_TYPES)
	message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
	set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE
	    STRING "choose the type of build"
	    FORCE
	    )

# Set the possible values of build type for cmake-gui/cmake
set_property(CACHE CMAKE_BUILD_TYPE
             PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
             
endif()

set(default_pic ON)
if ("${CMAKE_POSITION_INDEPENDENT_CODE}" STREQUAL "")
	message(STATUS "Setting PIC for all targets to '${default_pic}' as none was specified.")
	set(CMAKE_POSITION_INDEPENDENT_CODE default_pic CACHE
	    BOOL "Compile all targets with -fPIC."
	    FORCE)
endif()

set(default_shared_libs OFF)
if ("${BUILD_SHARED_LIBS}" STREQUAL "")
	message(STATUS "Setting 'build shared libraries' to '${default_shared_libs}' as none was specified.")
	set(BUILD_SHARED_LIBS default_shared_libs CACHE
	    BOOL "Compile shared libraries by default instead of static libraries."
	    FORCE)
endif()

# Export compile_commands.json file
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# if("${CMAKE_EXPORT_COMPILE_COMMANDS}" STREQUAL "")
# 	message(STATUS "Setting 'export_compile_commands' to '${default_compile_commands}' as no value was specified.")
# 	set(CMAKE_EXPORT_COMPILE_COMMANDS ${default_compile_commands} CACHE
# 	    BOOL "Export compile_commands.json file."
# 	    FORCE)
# endif()
