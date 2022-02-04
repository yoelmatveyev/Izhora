# Output 256-bit Fibonacci numbers and write "Hello world"

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

a:
.word		0,0,0,0,0,0,0,0

b:
.word		1,0,0,0,0,0,0,0

c:
.word		0,0,0,0,0,0,0,0

disp_addr:
.word		0x07F8

count:
.word		8

scrlines:
.word		128

a.value:
.word		a
b.value:
.word		b	
c.value:
.word		c


hello:	

.word 0b11001110010001110000010000000000,0b10010111010001000011000001000100
.word 0b00101001010001001000010000000000,0b10010100010001000100100001000101
.word 0b00101110010001001000010000000000,0b11110110010001000100100001010101
.word 0b00101010010001001000000000000000,0b10010100010001000100100001010101
.word 0b11001001011101110000010000000000,0b10010111011101110011000000101000

hello.count:
.word		2	
hello.addr:
.word		hello
hello.disp:
.word		0x070C	
hello.lines:
.word		4	

#---------------------------------------
addc: # Add unsigned integers TMP0=TMP0+TMP1, carry to TMP2

                subleq 1, $addc.newret
                add $=0x20000,$addc.newret
        	mov $addc.newret,$addc.ret
		mov $TMP0,$TMP3
		add $TMP1,$TMP0
        	zero $addc.newret
		zero $TMP2
		subleq 3,$TMP3
		jmp $addc.p
		subleq 3,$0
		jmp $addc.n
		subleq 3,$=1
		jmp $addc.ret
		zero $0
		subleq 1,$maxneg
		subleq 1,$=1
		jmp $addc.n
addc.p:
		zero $0
		subleq 3,$TMP1
		jmp $addc.ret
		subleq 3,$0
		jmp $addc.pn
		subleq 3,$=1
		jmp $addc.ret
		zero $0
		subleq 1,$maxneg
		subleq 1,$=1
		jmp $addc.pn
addc.n:
		zero $0
		subleq 3,$TMP1
		jmp $addc.pn
		subleq 3,$0
		jmp $addc.carry
		subleq 3,$=1
		jmp $addc.ret
		zero $0
		subleq 1,$maxneg
		subleq 1,$=1
		jmp $addc.carry
addc.pn:
		zero $0
		subleq 3,$TMP0
		jmp $addc.carry
		subleq 3,$0
		jmp $addc.ret
		subleq 3,$=1
		jmp $addc.carry
		zero $0
		subleq 1,$maxneg
		subleq 1,$=1
		jmp $addc.ret
addc.newret:
.word           0       
addc.carry:
		zero $0
		mov $=1,$TMP2
addc.ret:
.word		0

		# End of addc
#--------------------------------------

movx:		# Move a series of words

		subleq 1, $movx.newret
		add $=0x20000,$movx.newret
		mov $movx.newret,$movx.ret
		zero $movx.newret	
		add $movx.orig,$movx.addr1
		subleq 1,$movx.dest
		subleq 1,$=0
		subleq 1,$movx.addr2
		add $movx.dest,$movx.addr2z0
		subleq 1,$movx.dest
		subleq 1,$=0
		subleq 1,$movx.addr2z1
		zero $=0
		mov $movx.count,$TMP0
movx.begin:
		zero $=0
movx.addr2z0:
		subleq 1, $0
movx.addr2z1:	
		subleq 1, $0
movx.addr1:
		subleq 1,$0
		subleq 1,$=0
movx.addr2:
		subleq 1,$0
		add $=1,$movx.addr1
		subleq 1,$=1
		subleq 1,$=0
		subleq 1,$movx.addr2
		add $=1,$movx.addr2z0
		subleq 1,$=1
		subleq 1,$=0
		subleq 1,$movx.addr2z1
		zero $=0
		subleq 1,$=1
		subleq $movx.end, $TMP0
		jmp $movx.begin
movx.newret:
.word		0	
movx.count:
.word		0
movx.orig:
.word		a
movx.dest:	
.word		0
movx.end:
		sub $movx.orig,$movx.addr1
		sub $movx.count,$movx.addr1
		sub $movx.dest,$movx.addr2
		sub $movx.count,$movx.addr2
		sub $movx.dest,$movx.addr2z0
		sub $movx.count,$movx.addr2z0
		sub $movx.dest,$movx.addr2z1
		sub $movx.count,$movx.addr2z1
		zero $=0 
movx.ret:
.word		0
	
		# End of movx
#--------------------------------------
addx:		# Add 2 groups of n words

		subleq 1, $addx.newret
		add $=0x20000,$addx.newret
		mov $addx.newret,$addx.ret
		zero $addx.newret
		zero $=0
		mov $addx.count,$addx.n
	 	zero $addx.carry
		subleq 1,$addx.a
		subleq 1,$=0
		subleq 1,$addx.a0
		add $addx.a,$addx.a1
		subleq 1,$addx.a
		subleq 1,$=0
		subleq 1,$addx.az0
		add $addx.a,$addx.az1
		subleq 1,$addx.b
		subleq 1,$=0
		subleq 1,$addx.b0
		zero $=0
addx.loop:
		zero $TMP0
addx.a0:	
		subleq 1, $0
		subleq 1, $=0
		subleq 1, $TMP0
		zero $=0
		mov $addx.carry, $TMP1
		call1 $addc
		zero $=0
		mov $TMP2, $addx.carry
		zero $TMP1
addx.b0:
		subleq 1, $0
		subleq 1, $0
		subleq 1, $TMP1
		zero $0
		call1 $addc
 		add $TMP2, $addx.carry
addx.az0:
		subleq 1, $0
addx.az1:
		subleq 1, $0
		zero $0
		subleq 1, $TMP0
		subleq 1, $0
addx.a1:
		subleq 1, $0
		add $=1, $addx.a1
		subleq 1, $=1
		subleq 1, $=0
		subleq 1, $addx.a0
		add $=1,$addx.b0
		subleq 1, $=1
		subleq 1, $=0
		subleq 1, $addx.az0
		add $=1,$addx.az1
		subleq 1,$=1
		subleq $addx.end,$addx.n
		jmp $addx.loop
addx.end:
		sub $addx.count,$addx.a0
		sub $addx.count,$addx.b0
		sub $addx.count,$addx.a1
		sub $addx.count,$addx.az0
		sub $addx.count,$addx.az1
		sub $addx.a,$addx.a0
		sub $addx.b,$addx.b0
		sub $addx.a,$addx.a1
		sub $addx.a,$addx.az0
		sub $addx.a,$addx.az1
		jmp $addx.ret	
addx.n:
.word		0	
addx.carry:
.word		0
addx.newret:
.word		0	
addx.a:
.word		a
addx.b:
.word		b
addx.count:
.word		0	
addx.ret:
.word		0
	
		# End of addx
#--------------------------------------
	
.global	_start


_start:

		mov $count,$addx.count
		mov $count,$movx.count

main_loop:
		mov $a.value,$movx.orig
		mov $c.value,$movx.dest
		call1 $movx
		mov $c.value,$addx.a
		mov $b.value,$addx.b
		call1 $addx
		mov $b.value,$movx.orig
		mov $a.value,$movx.dest
		call1 $movx
		mov $c.value,$movx.orig
		mov $b.value,$movx.dest
		call1 $movx
		mov $a.value,$movx.orig
		mov $disp_addr,$movx.dest
		call1 $movx
		sub $count,$disp_addr
		zero $0
		subleq 1,$=1
		subleq $break,$scrlines
		jmp $main_loop
break:

		mov $hello.addr,$movx.orig
		mov $hello.disp,$movx.dest
		mov $hello.count,$movx.count
	
hello.loop:

		call1 $movx
		sub $count,$movx.dest
		add $hello.count,$movx.orig
		subleq 1,$=1
		subleq 1,$hello.lines
		subleq $hello.loop,$0

end:	
