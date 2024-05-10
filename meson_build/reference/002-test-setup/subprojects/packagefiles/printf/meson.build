project('printf-patch',
	'c'
)

#############################
# Printf Dependency Targets #
#############################

printf_files = files('src/printf/printf.c')

# Both directories are included so `#include "printf/printf.h"` and `#include "printf.h"` work
printf_includes = include_directories(['src', 'src/printf'], is_system: true)

libprintf = static_library(
	'printf',
    printf_files,
    include_directories: printf_includes,
    c_args: [
		'-DPRINTF_ALIAS_STANDARD_FUNCTION_NAMES_HARD',
		'-DPRINTF_INCLUDE_CONFIG_H=0'
	]
)

libprintf_dep = declare_dependency(
	include_directories: printf_includes,
	link_with: libprintf,
	compile_args: [
		'-DPRINTF_ALIAS_STANDARD_FUNCTION_NAMES_HARD'
	]
)
