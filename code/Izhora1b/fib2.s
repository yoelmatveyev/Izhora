# Output Fibonacci numbers on the screen

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

=8:
.word		8
	
.global _start

_start:
		mov $=1,$TMP1
loop:
		mov $TMP2,$TMP3
		add $TMP1,$TMP2
		mov $TMP3,$TMP1
		subleq 1,$TMP2
		subleq 1,$TMP4
screen:	
		subleq 1,$0x07FF
		zero $TMP4
		sub $=8,$screen
		jmp $loop
