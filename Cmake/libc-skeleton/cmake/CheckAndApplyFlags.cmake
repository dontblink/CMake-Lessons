#################
# Helper Macros #
#################

#change - to _ to generate safe variable names
macro(make_safe_varname input_string output_var)
	string(REPLACE - _ ${output_var} ${input_string})
endmacro()

#use this function to promote an input argument that represents a list
# such that two layers of dereferencing aren't needed
# This enables supporting both string and variable inputs with a function arg
macro(check_and_double_deref input)
	if(NOT "${${${input}}}" STREQUAL "")
		set(${input} ${${${input}}})
	endif()
endmacro()

#########################
# Compiler Flag checker #
#########################

function(apply_supported_compiler_flags lang target scope flag_list)		
	if(${CMAKE_VERSION} LESS "3.18")
		if(${lang} STREQUAL C)
			apply_supported_c_compiler_flags(${target} ${scope} ${flag_list})
		elseif(${lang} STREQUAL CXX)
			apply_supported_cxx_compiler_flags(${target} ${scope} ${flag_list})
		else()
			message(FATAL_ERROR "Language ${lang} is not supported by this function.")
		endif()
	else()
		include(Check${lang}CompilerFlag)
		
		check_and_double_deref(flag_list)
		foreach(flag ${flag_list})
			make_safe_varname(${flag} flag_var)
			cmake_language(CALL check_${lang}_compiler_flag ${flag} ${flag_var})
		
			if(${flag_var})
				target_compile_options(${target} ${scope} ${flag})
			endif()
		endforeach()
	endif()
endfunction()

#######################
# Linker Flag Checker #
#######################

if(${CMAKE_VERSION} LESS "3.18")

	function(apply_supported_linker_flags lang target scope flag_list)
		if(${lang} STREQUAL C)
			apply_supported_c_linker_flags(${target} ${scope} ${flag_list})
		elseif(${lang} STREQUAL CXX)
			apply_supported_cxx_linker_flags(${target} ${scope} ${flag_list})
		else()
			message(FATAL_ERROR "Language ${lang} is not supported by this function")
		endif()
	endfunction()

else()

	include(CheckLinkerFlag)
	function(apply_supported_linker_flags lang target scope flag_list)
		check_and_double_deref(flag_list)
		foreach(flag ${flag_list})
			make_safe_varname(${flag} flag_var)
			check_linker_flag(${lang} ${flag} ${flag_var})
			if(${flag_var})
				target_link_options(${target} ${scope} ${flag})
			endif()
		endforeach()
	endfunction()

endif()
