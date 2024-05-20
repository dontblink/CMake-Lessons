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

# Linker Arguments and Dependencies #######################
linker_script_flags = []
linker_script_deps = []

foreach path : meson.get_external_property('linker_paths', [''])
	if path != ''
		linker_script_flags += '-L' + meson.source_root() / path
	endif
endforeach

foreach script : meson.get_external_property('linker_scripts', [''])
	if script != ''
		linker_script_flags += '-T' + script
	endif
endforeach

foreach dep : meson.get_external_property('linker_depends', [''])
	if dep != ''
		linker_script_deps += meson.source_root() / dep
	endif
endforeach


## Subprojects
##
printf_subproject = subproject('printf')
# libprintf_dep = printf_subproject.get_variable('libprintf_dep')
# libprintf_native_dep = printf_subproject.get_variable('libprintf_native_dep')
printf_files_dep = printf_subproject.get_variable('printf_files_dep')
printf_includes = printf_subproject.get_variable('printf_includes')

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


files_to_lint = []
##
## subdirectories
##
subdir('arch')
subdir('src')
subdir('test')

#Tooling #####################

subdir('docs/Doxygen')

clangformat = find_program('clang-format', required: false, disabler: true)
if clangformat.found()
	run_target('format', 
		command: 'tools/format.sh')

	run_target('format-patch',
		command: 'tools/format_patch.sh')
endif

cppcheck = find_program('cppcheck', required: false, disabler: true)
if cppcheck.found()
	run_target('cppcheck',
		command: 'tools/cppcheck.sh',
	)
	run_target('cppcheck-xml',
		command: ['tools/cppcheck.sh', 'xml'],
	)
endif

clangtidy = find_program('clang-tidy', required: false, disabler: true)
if clangtidy.found()
	run_target('clang-tidy',
		command: [
			'tools/clang-tidy.sh',
			files_to_lint,
		],
	)
endif

lizard = find_program('lizard', required: false, disabler: true)
if lizard.found()

	lizard_default_args = [
		# Exclude these directories
		'x', './buildresults/*',
		'x', './subprojects/*',
		# Configuration
		'--length', '75', # Fail when functions are longer than this
		'--CCN', '10', # Fail over this CCN
		'--arguments', '10', # Fail at this arg count
	]
	run_target('complexity',
		command: [
			lizard,
			lizard_default_args,
			'-w' # only displays violation warnings
		],
	)

	run_target('complexity-full',
		command: [
			lizard,
			lizard_default_args,
		],
	)

	complexity_xml = custom_target('complexity.xml',
		output: 'complexity.xml',
		command: [
			lizard,
			lizard_default_args,
			'--xml',
		],
		capture: true, #tell meson to capture `stdout` and save it to our output
		build_always_stale: true, #tell meson to run this target every time it is invoked, regardless of whether `complexity.xml already exists
		build_by_default: false,
	)

	# Meson expects us to use the file name of the output to trigger the rule
	# To create a consistent interface, we create an alias
	alias_target('complexity-xml', complexity_xml)
endif

##
## custom targets
##
run_target('clear-test-results',
	command: meson.project_source_root() + '/tools/clear_test_results.sh'
)

run_target('package', 
	command: [
		'tools/package.sh',
		'-a', host_machine.cpu_family(),
		'-c', host_machine.cpu(),
		'-s', host_machine.system(),
		'-v', meson.project_version(),
	],
)

run_target('package-native', 
	command: [
		'tools/package.sh',
		'-a', build_machine.cpu_family(),
		'-c', build_machine.cpu(),
		'-s', build_machine.system(),
		'-v', meson.project_version(),
		'-n',
	],
)
