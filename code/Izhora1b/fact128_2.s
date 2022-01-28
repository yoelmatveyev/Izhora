# Output 128-bit factorials

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

n:
.word 		0
f0:
.word		1
f1:
.word		0
f2:
.word		0
f3:
.word		0
=8:
.word		8
	
.global _start

_start:
		add $=1,$n
		mov $n,$TMP1
		mov $f0,$TMP2
		mov $f1,$TMP3
		mov $f2,$TMP4
		mov $f3,$TMP5
mul:
		zero $=0
		subleq 1,$TMP2
		subleq 1,$=0
		subleq $leq1,$f0
		jmp skip1
leq1:
		subleq $skip1,$TMP6
		add $=1,$f1
skip1:
		zero $TMP6
		zero $=0
		subleq 1,$TMP3
		subleq 1,$=0
		subleq $leq2,$f1
		jmp skip2
leq2:
		subleq $skip2,$TMP6
		add $=1,$f2
skip2:
		zero $TMP6
		zero $=0
		subleq 1,$TMP4
		subleq 1,$=0
		subleq $leq3,$f2
		jmp skip3
leq3:
		subleq $skip3,$TMP6
		add $=1,$f3
skip3:
		add $TMP5,$f3
		subleq 1,$=1
		subleq $lb1,$TMP1
		jmp $mul
lb1:
		zero $TMP1
		subleq 1,$f0
		subleq 1,$TMP1
screen0:
		subleq 1,$0x07F8	
		sub $=8,$screen0
		zero $TMP1
		subleq 1,$f1
		subleq 1,$TMP1
screen1:
		subleq 1,$0x07F9
		sub $=8,$screen1
		zero $TMP1
		subleq 1,$f2
		subleq 1,$TMP1
screen2:
		subleq 1,$0x07FA
		sub $=8,$screen2
		zero $TMP1
		subleq 1,$f3
		subleq 1,$TMP1
screen3:
		subleq 1,$0x07FB
		sub $=8,$screen3
		jmp $_start
