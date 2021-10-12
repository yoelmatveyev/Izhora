# Hello World!

.stdmacros # Including standard macrocommands
.stdvars # Including standard variables

sub $wrd0,$0x0403
sub $wrd1,$0x0402
sub $wrd2,$0x0407
sub $wrd3,$0x0406
sub $wrd4,$0x040B
sub $wrd5,$0x040A
sub $wrd6,$0x040F
sub $wrd7,$0x040E
sub $wrd8,$0x0413
sub $wrd9,$0x0412

# Addition inverses (negatives) of 10 words making up the "Hello World!" message

wrd0:
.word $0x68BBCFBC
wrd1:
.word $0x31B8FC00
wrd2:
.word $0x6BBBB7BB
wrd3:
.word $0xD6BB7C00
wrd4:
.word $0x09BBB7AB
wrd5:
.word $0xD1BB7C00
wrd6:
.word $0x6BBBB7AB
wrd7:
.word $0xD5BB8000
wrd8:
.word $0x6888CFD8
wrd9:
.word $0x3688FC00
