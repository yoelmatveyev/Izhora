# Output prime numbers

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

=2:		
.word 		2
n:
.word		1
=4:
.word		4
=8:
.word		8
	
.global _start

_start:
		mov $=4,$TMP4
next:				# Next number
		add $=2,$n
		mov $=1,$TMP1
prime_check:			# Primality check (TMP3)
		add $=2,$TMP1
		mov $n,$TMP3
		mov $n,$TMP2 
		subleq 1,$TMP1
		subleq $prime,$TMP2
	
div:			# Divisibility check: (TMP3%TMP1==0)
	
		zero $=0
		subleq 1,$TMP1
		subleq $leq, $TMP3
		jmp $div
leq:
		subleq $divl,$=0
ndivl:	
		jmp $prime_check
divl:			# Not a prime
		jmp $next
prime:			# A prime
		zero $TMP5
		subleq 1,$n
		subleq 1,$TMP5
display:
		subleq 1,$0x0403 # Upper left corner of the display
		sub $=1,$display
		zero $=0	
		subleq 1,$=1
		subleq $next_line,$TMP4
		jmp $next
next_line:	
		add $=8,$display
		jmp $_start
