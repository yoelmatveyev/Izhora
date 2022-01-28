# Output scancodes of pressed keys

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables
	
.global _start

_start:
		zero $=0
		subleq $_start, $0xFFFF
		subleq 1,$=0
display:
		subleq 1,$0x07FF
		sub $=1,$display
		zero $0xFFFF
		jmp $_start
		
