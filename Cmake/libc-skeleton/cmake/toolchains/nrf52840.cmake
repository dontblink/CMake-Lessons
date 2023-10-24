set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
# Represents the name of the specific processor type, e.g. Cortex-M4
set(CPU_NAME cortex-m4)

# make cmake toolchain variables to our toolchain's program names
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(AS arm-none-eabi-as)
set(CMAKE_AR arm-none-eabi-gcc-ar)
set(OBJCOPY arm-none-eabi-objcopy)
set(OBJDUMP arm-none-eabi-objdump)
set(SIZE arm-none-eabi-size)

#tell cmake where to search for files when using the find_* functions
# if set to ONLY, then only the roots in cmake_find_root_path (i.e. the host machine)
# will be searched. If set to NEVER, then the roots in CMAKE_FIND_ROOT_PATH will
# be ignored and only the build machien root will be used
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Test compiles will use static libraries, so we won't need to define linker flags
# and scripts for linking to succeed
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# set compilation flags for our target
# compile this program for a cortex-m4
# use the hard floating point ABI, so floating point instructions will go to the FPU
#	FPU standard is fpv4-sp-d16
# use the ARM architecture Procedure Call Standard as the abi
# Generate thumb instructions
set(CMAKE_C_FLAGS_INIT
    "-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb -fdata-sections -ffunction-sections"
    CACHE
    INTERNAL "Default C compiler flags.")
set(CMAKE_CXX_FLAGS_INIT
    "-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mthumb -fdata-sections -ffunction-sections"
    CACHE
    INTERNAL "Default C++ compiler flags.")
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "-Wl, --gc-sections"
    CACHE
    INTERNAL "Default linker flags.")
