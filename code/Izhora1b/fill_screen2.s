# Fill 0x0400-0x07FF

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

scr_end:
.word		0x0400
	
.global _start

_start:
		zero $=0
		subleq 1, $=1
index:
		subleq 1, $0x07ff
		sub $=1, $index
		sub $=1, $scr_end
		zero $=0
		subleq $end, $scr_end
		jmp _start
end:		
