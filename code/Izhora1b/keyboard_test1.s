# Display #FFFF (which reflects the keyboard)

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables
	
.global _start

_start:
		mov $0xFFFF, $0x0400
		jmp _start
end:		
