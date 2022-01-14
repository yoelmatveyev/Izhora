# Hello World!
# A version for Izhora1b 

.stdmacros # Include standard macrocommands
.stdvars # Include standard variables

i:
.word 5
add_scr_addr:
.word 8
add_data_addr:
.word 2
	
.global _start # By default, PC will be set to this label

_start:
	zero $=0
mov1:
	subleq 1,$wrd0
	subleq 1,$=0
mov2:	
	subleq 1,$0x07FF
	zero $=0
mov3:
	subleq 1,$wrd1
	subleq 1,$=0
mov4:	
	subleq 1,$0x07FE

	add $add_data_addr,$mov1
	sub $add_scr_addr,$mov2
	add $add_data_addr,$mov3
	sub $add_scr_addr,$mov4

	subleq 1,$=1
	subleq 1,$i
	subleq $_start,$=0

wrd0:
.word	0
wrd1:
.word	0

.org wrd0
	
.word 0b10010111010001000011000001000100,0b11001110010001110000010000000000
.word 0b10010100010001000100100001000101,0b00101001010001001000010000000000
.word 0b11110110010001000100100001010101,0b00101110010001001000010000000000
.word 0b10010100010001000100100001010101,0b00101010010001001000000000000000
.word 0b10010111011101110011000000101000,0b11001001011101110000010000000000	
