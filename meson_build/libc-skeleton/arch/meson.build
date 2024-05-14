arch_template = '@0@/include'

host_arch = host_machine.cpu_family()
build_arch = build_machine.cpu_family()

build_machine_arch_specific_sys_includes = include_directories( arch_template.format(build_arch), is_system: true)
host_machine_arch_specific_sys_includes = include_directories( arch_template.format(host_arch), is_system: true)

subdir(host_arch)
if (host_arch != build_arch)
	subdir(build_arch)
endif
