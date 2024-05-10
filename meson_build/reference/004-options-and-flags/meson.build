project('Embedded Artistry libc',
	['c', 'cpp'],
	default_options : [
		'warning_level=3',
		'werror=false',
		'c_std=c11',
		'cpp_std=c++11',
	],
	license: 'MIT',
	meson_version: '>=0.56.0',
	version: '1.0')

################################
# Project Options and Settings #
################################

c_compiler = meson.get_compiler('c')

disable_unimplemented_apis = get_option('hide-unimplemented-libc-apis')
enable_gnu_src = get_option('enable-gnu-extensions')

## Left for demonstration purposes, removed in the next example.
# add_project_arguments('-Wno-unused-parameter', language: 'c')

add_project_arguments(
	c_compiler.get_supported_arguments(
		'-Wno-unknown-pragmas',
		'-Wno-nonnull',
		'-Wno-nonnull-compare',
	),
	language: 'c'
)

###############
# Subprojects #
###############

printf_subproject = subproject('printf')
libprintf_dep = printf_subproject.get_variable('libprintf_dep')
printf_includes = printf_subproject.get_variable('printf_includes')

openlibm_subproject = subproject('openlibm')
openlibm_dep = openlibm_subproject.get_variable('openlibm_dep')
openlibm_includes = openlibm_subproject.get_variable('openlibm_includes')

#####################
# CMocka Dependency #
#####################

cmocka_dep = dependency('cmocka', required: false, fallback: ['cmocka', 'cmocka_dep'])

# Uncomment if your build fails on Linux with CMocka installed due to -nostdinc,
# and remove the line above.
# cmocka_subproject = subproject('cmocka')
# cmocka_native_dep = cmocka_subproject.get_variable('cmocka_native_dep')

#######################
# Process Source Tree #
#######################

subdir('src')
subdir('test')

##################
# Custom Targets #
##################

run_target('clear-test-results',
	command: meson.project_source_root() + '/tools/clear_test_xml.sh'
)
