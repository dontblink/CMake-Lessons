################
# Printf Tests #
################

printf_tests = executable('printf_tests',
	sources: files('test_suite.cpp'),
	native: true
)

test('printf_tests',
	printf_tests,
	args: ['-s', '-r', 'junit', '-o', meson.build_root() + '/test/printf_tests.xml']
)

run_target('printf-tests',
	command: printf_tests
)

run_target('printf-tests-xml',
	command: [printf_tests, '-s', '-r', 'junit', '-o', meson.build_root() + '/test/printf_tests.xml']
)
