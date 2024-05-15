libc_test_files = files(
	'main.c',
	'ctype/ctype_tests.c',
	'ctype/isalnum.c',
	'ctype/isalpha.c',
	'ctype/isascii.c',
	'ctype/isblank.c',
	'ctype/iscntrl.c',
	'ctype/isdigit.c',
	'ctype/isgraph.c',
	'ctype/islower.c',
	'ctype/isprint.c',
	'ctype/ispunct.c',
	'ctype/isspace.c',
	'ctype/isupper.c',
	'ctype/isxdigit.c',
	'ctype/toascii.c',
	'ctype/tolower.c',
	'ctype/toupper.c',
	'stdlib/abs.c',
	'stdlib/atof.c',
	'stdlib/atoi.c',
	'stdlib/atol.c',
	'stdlib/atoll.c',
	'stdlib/bsearch.c',
	'stdlib/calloc.c',
	'stdlib/div.c',
	'stdlib/heapsort.c',
	'stdlib/imaxabs.c',
	'stdlib/imaxdiv.c',
	'stdlib/labs.c',
	'stdlib/ldiv.c',
	'stdlib/llabs.c',
	'stdlib/lldiv.c',
	'stdlib/qsort_r.c',
	'stdlib/qsort.c',
	'stdlib/rand.c',
	'stdlib/realloc.c',
	'stdlib/stdlib_tests.c',
	'stdlib/strtod.c',
	'stdlib/strtof.c',
	'stdlib/strtol.c',
	'stdlib/strtoll.c',
	'stdlib/strtoul.c',
	'stdlib/strtoull.c',
	'string/memcmp.c',
	'string/memcpy.c',
	'string/memmem.c',
	'string/memmove.c',
	'string/memset.c',
	'string/strcat.c',
	'string/strchr.c',
	'string/strcmp.c',
	'string/strcpy.c',
	'string/strdup.c',
	'string/string_tests.c',
	'string/strlen.c',
	'string/strncat.c',
	'string/strncmp.c',
	'string/strncpy.c',
	'string/strndup.c',
	'string/strnlen.c',
	'string/strnstr.c',
	'string/strrchr.c',
	'string/strstr.c',
	'string/strtok.c',
	'test/rand.c'
)

# if c_compiler.has_argument('-Wno-unused-parameter')
# 	libc_test_flags += '-Wno-unused-parameter'
# endif
# there's a function that does all of this in one go
libc_test_flags = native_c_compiler.get_supported_arguments( '-Wno-unused-parameter')

#Map File Generation ################################

libc_test_map = native_map_file.format(meson.current_build_dir() + '/libc_test')

#Libc test executable ###############################
libc_tests = executable(
	'libc_test',
	libc_test_files,
	dependencies: [cmocka_native_dep, libc_hosted_native_dep],
	link_args: libc_test_map,
	c_args: libc_test_flags,
	native: true,
	install: false,
	build_by_default: false,
)

#Libc test targets ################################################
test_output_dir = 'CMOCKA_XML_FILE=' + meson.project_build_root() + '/test/%g.xml' # %g tells CMocka to output each test group to its own file
test('libc_tests', libc_tests, env: [test_output_dir])

run_target('libc-tests', 
	command: libc_tests
)
run_target('libc-tests-xml', 
	command: libc_tests, 
	env: [test_output_dir],
	depends: libc_tests
)

#Libc Sample App ##################################################
if meson.is_cross_build()
	host_objcopy = find_program(meson.get_external_property('objcopy'))
	
	# ld_file = meson.current_source_dir()/'app/STM32F103VBIx_FLASH.ld'

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

	sample_app = executable('sample_app',
		'app/main.c',
		dependencies: libc_dep,
		link_args: [
			linker_script_flags,
			native_map_file.format(meson.current_build_dir() + '/sample_app'),
		],
		link_depends: linker_script_deps,
		native: false,
	)
	bin_output = 'sample_app.bin'
	hex_output = 'sample_app.hex'

	sample_app_bin = custom_target(
		bin_output,
		output: bin_output,
		input: sample_app,
		command: [host_objcopy, '-O', 'binary', '@INPUT@', '@OUTPUT@'],		
		build_by_default: true,
	)
	sample_app_hex = custom_target(
		hex_output,
		output: hex_output,
		input: sample_app,
		command: [host_objcopy, '-O', 'ihex', '@INPUT@', '@OUTPUT@'],	
		build_by_default: true,
	)


endif
