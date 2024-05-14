project('Embedded Artistry libc',
	['c', 'cpp'],
	default_options : [
		'warning_level=3',
		'werror=false',
		'c_std=c11',
		'build.c_std=c11',
		'cpp_std=c++11',
		'build.cpp_std=c++11',
		'buildtype=custom',
		'debug=true',
		'optimization=g'
	],
	license: 'MIT',
	meson_version: '>=1.3.0',
	version: '1.0')

native_c_compiler = meson.get_compiler('c', native: true)
host_c_compiler = meson.get_compiler('c', native: false)
native_c_compiler_id = native_c_compiler.get_id()
host_c_compiler_id = host_c_compiler.get_id()

# build_machine_arch_specific_includes = include_directories('arch/' + build_machine.cpu_family() + '/include')
# host_machine_arch_specific_includes = include_directories('arch/' + host_machine.cpu_family() + '/include')
# build_machine_arch_specific_sys_includes = include_directories('arch/' + build_machine.cpu_family() + '/include', is_system: true)
# host_machine_arch_specific_sys_includes = include_directories('arch/' + host_machine.cpu_family() + '/include', is_system: true)

##
## Options
##
disable_unimplemented_apis = get_option('hide-unimplemented-libc-apis')
enable_gnu_src = get_option('enable-gnu-extensions')
disable_builtins = get_option('disable-builtins')
disable_stack_protection = get_option('disable-stack-protection')
debug = get_option('debug')

debug_options = ['-DDEBUG']
if debug
	add_project_arguments(debug_options,
		language: ['c', 'cpp'], native: true)
	add_project_arguments(debug_options,
		language: ['c', 'cpp'], native: false)
endif

##
## global project arguments
##
project_arguments = [
	'-Wno-unknown-pragmas',
	'-Wno-nonnull',
	'-Wno-nonnull-compare',
	'-Wno-stringop-truncation',	
]

add_project_arguments(
	native_c_compiler.get_supported_arguments(project_arguments),
	language: 'c',
	native: true,
)

add_project_arguments(
	host_c_compiler.get_supported_arguments(project_arguments),
	language: 'c',
	native: false,
)


##
## Subprojects
##
printf_subproject = subproject('printf')
# libprintf_dep = printf_subproject.get_variable('libprintf_dep')
# libprintf_native_dep = printf_subproject.get_variable('libprintf_native_dep')
printf_includes = printf_subproject.get_variable('printf_includes')
printf_files_dep = printf_subproject.get_variable('printf_files_dep')

openlibm_subproject = subproject('openlibm')
openlibm_dep = openlibm_subproject.get_variable('openlibm_dep')
openlibm_includes = openlibm_subproject.get_variable('openlibm_includes')

# use installed libarary, if not found, fallback to wrap file and create subproject
# cmocka_dep = dependency('cmocka', required: false, fallback: ['cmocka', 'cmocka_dep'])

# we can't use this because the installed cmocka has headers in /usr/include, which is excluded by
# -nostdinc :(
# cmocka_native_dep = dependency('cmocka', native: true, required: false,
# 	fallback: ['cmocka', 'cmocka_native_dep'])
cmocka_native_dep = dependency('cmocka', native: true, fallback: ['cmocka', 'cmocka_native_dep'])

#Handle case where Linux fails to build because cmocka.h can't be found due to `-nostdinc`:
if (cmocka_native_dep.type_name() == 'pkgconfig' and \
	native_c_compiler.has_header(
		'cmocka.h', 
		args: '-nostdinc',
		dependencies: cmocka_native_dep.partial_dependency(compile_args: true)) == false)
	
	#Header isn't found with `-nostdinc`, even though library is: revert to subproject
	cmocka_subproject = subproject('cmocka')
	cmocka_native_dep = cmocka_subproject.get_variable('cmocka_native_dep')
endif

#Map File Generation ################################
# map_link_arg = '-Wl,-Map,@0@.map'
# libc_test_map = map_link_arg.format(meson.current_build_dir() + '/libc_test')
if native_c_compiler.has_link_argument('-Wl,-map,test.map')
	native_map_file = '-Wl,-map,@0@.map'
elif native_c_compiler.has_link_argument('-Wl,-Map,test.map')
	native_map_file = '-Wl,-Map,@0@.map'
else
	warning('Native toolchain does not support Map file generation')
	native_map_file = []
endif

if host_c_compiler.has_link_argument('-Wl,-map,test.map')
	host_map_file = '-Wl,-map,@0@.map'
elif host_c_compiler.has_link_argument('-Wl,-Map,test.map')
	host_map_file = '-Wl,-Map,@0@.map'
elif host_c_compiler.has_multi_link_arguments('--specs=nosys.specs', '-Wl,-Map,test.map')
	# arm-gcc will fail the check without --specs=nosys.specs
	host_map_file = '-Wl,-Map,@0@.map'
else
	warning('host toolchain does not support Map file generation')
	host_map_file = []
endif

##
## subdirectories
##
subdir('arch')
subdir('src')
subdir('test')
##
## custom targets
##
run_target('clear-test-results',
	command: meson.project_source_root() + '/tools/clear_test_results.sh'
)
