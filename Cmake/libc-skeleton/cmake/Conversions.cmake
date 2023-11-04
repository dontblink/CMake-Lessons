function(convert_to_hex target)
	add_custom_command(TARGET ${target} POST_BUILD 
	                  COMMAND ${CMAKE_OBJCOPY} -O ihex ${target} ${target}.hex
	                  BYPRODUCTS ${target}.hex )
endfunction()

function(convert_to_bin target)
		add_custom_command(TARGET ${target} POST_BUILD 
	                  COMMAND ${CMAKE_OBJCOPY} -O binary ${target} ${target}.bin
	                  BYPRODUCTS ${target}.bin)
endfunction()
