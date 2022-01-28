# Output pseudo-random mess on the screen

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

seed:
.word		$0x10111010110011001010000110011101
	
.global _start

_start:
		mov $seed,$TMP1
loop:
		mov $TMP2,$TMP3
		add $TMP1,$TMP2
		mov $TMP3,$TMP1
		subleq 1,$TMP2
		subleq 1,$TMP4
screen:	
		subleq 1,$0x07FF
		zero $TMP4
		sub $=1,$screen
		jmp $loop
