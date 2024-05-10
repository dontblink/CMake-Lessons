project('Embedded Artistry libc',
	'c',
	default_options : [
		'c_std=c11'
	],
	license: 'MIT',
	meson_version: '>=0.56.0',
	version: '1.0')

###############
# Subprojects #
###############

printf_subproject = subproject('printf')
libprintf_dep = printf_subproject.get_variable('libprintf_dep')

#######################
# Process Source Tree #
#######################

subdir('src')
