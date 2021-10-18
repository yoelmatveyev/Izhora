# Output Fibonacci numbers on the screen

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

my1:
.word 		1
my0:
.word		0
=4:
.word		4
=8:
.word		8
	
.global _start

_start:

		mov $=4,$TMP2
horizontal_loop:
		zero $TMP1
		subleq 1, $my1
		subleq 1, $TMP1
screen:	
		subleq 1,$0x0403 # Upper left corner of the display
		add  $my0,$my1
		movn $TMP1,$my0
		sub $=1,$screen
		zero $=0	
		subleq 1,$=1
		subleq $next_line,$TMP2
		jmp $horizontal_loop
next_line:	
		add $=8,$screen
		jmp $_start
