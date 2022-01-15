# Izhora
Izhora is a fully operational universal computer build as a large pattern constructed in Fireworld2, a simple 4-state cellular automation rule invented by me (Yoel Matveyev) in 2020. Programming examples in this repository, written in an experimental assembler and compiled to machine code, include versions of the classic "Hello World", Fibonacci numbers, primes and 128-bit factorials. Machine code can be loaded to the actual machine by a Golly Python script; another script downloads the machine's current state to a file. Programs can be tested and run (about four orders of magnitude faster than on the actual cellular automation) by a basic emulator, written in Common Lisp.

The rule, Fireworld2, is based on Fireworld, a very simple 3-state cellular automation I had discovered in 2001. Fireworld has been proven (by me) to be Turing-complete; however, it lacks stable reflectors and splitters, which makes circuitry construction very tedious due to timing issues. Fireworld2 is a natural superset of Fireworld with an additional wiring state. "Electrons", i.e. signals bound to the wires, run on top of immutable wire structures. I would like to thank Brian Prentice for giving me some inspiration by his rule Wilfred invented as a superset of Brian's Brain - a well known rule proven (also by me) to be Turing-complete. Soon after the invention of Fireworld2 I have discovered that it's surprisingly suitable for computation. Simple constuctions act naturally as logic gates, reflectors and splitters, stable bit registers, flip-flops, signal generators etc. All this gives a tremendous enhancement to the computational usability of the original Fireworld and largely eliminates the timing difficulties.

In 2017 I wrote a simple virtual machine, which uses balanced ternary logic instead of binary. It's called Nutes, the reverse of Setun, the historical Soviet computer notable for being the only ternary mainframe ever created. Setun is a river in outskirts of Moscow. Izhora is a river in outskirts of St. Petersburg, named after the ancient Finno-Ugric tribe indigenous to the area.

There are currently two basic versions of the computer, Izhora 1 (October 2021) and Izhora 1b (January 2022). Both have 256k of 32-bit word-addressable XOR-writable RAM, a 32-bit accumulator and a 16-bit program counter. There is only one operation: a variety of Subleq known to be Turing-complete. On each cycle, the CPU reads a 32-bit word from the RAM and interprets its 16 highest bits and an absolute jump address and the lowest 16 bits as an operand address. The accumulator is them subtracted from the operand; the result is stored in both the accumulator and the operand. If the result was zero or negative, the CPU branches to the jump address; otherwise it proceeds to the next instruction. 

As simple as it is, Subleq systems are known to be practical. There is even a full-fledged OS with a C-like compiler written for an emulated 64-bit Subleq computer, called Dawn OS.

The RAM has a NUMA architecture. Cells located close to the CPU are accessed several times faster than the furthest ones. 

**Izhora 1** has a 128x64 little-endian up-to-bottom display. Lower addresses are reflected on the top. 

**Izhora 1b** has a 256x128 little-endian bottom-up display. Lower addresses are reflected lower. 

The is also a version of Izhora 1 with a keyboard, called **Izhora 1a**.

The display memory in both machines starts at #0400. Note that since the machine was 32-bit addressing, #100 means 1024, not 256 bytes. The lowest 4k of the memory should be used for common library functions and variables.

Izhora 1b has also a full keyboard with two modifier keys, conditionally mapped to the memory address 0xFFFF. If 0xFFFF contains 0, the keyboard controller writes the scancode to this address and gets ready for the next key scan; otherwise, it preserver the code of the first key pressed and waits for 0xFFFF to get cleared.

Some work has been already done toward a new version of the computer that will have, hopefully, RISC features implemented by mapping some jump addresses to other operations, relative addressing mode, several registers with an advanced ALU, one or two stacks etc. However, the machine as it now is fun to program. 

Although the computer is fully operational, each operation takes about 40,000 generations on average. Programs longer than 10-20k will inevitably slow down Golly's hashlife algorithm. Don't expect to see more than 100 operations per second. It is, after all, a large cellular automation patterns with millions of cells. The only way to run it faster is currently to download the machine's state, process it by the emulator, and upload it back to the machine. A simulator running it inside Golly is yet to be written.

# Golly scripts

To load a program, add the [Fireworld2.rule](https://github.com/yoelmatveyev/Izhora/blob/main/Golly/Fireworld2.rule) to your Golly rule directory, open the pattern [Izhora.rle](https://github.com/yoelmatveyev/Izhora/blob/main/Golly/Izhora1.rle) or [Izhora.mc](https://github.com/yoelmatveyev/Izhora/blob/main/Golly/Izhora1.mc) into Golly. then run the [load script](https://github.com/yoelmatveyev/Izhora/blob/main/Golly/scripts/izhora_load.py).

The format of raw images is as follows:

Any line containing # is treated as a comment. Addresses and register values are written in hex without any delimiters. Omitted values are treated as 0, e.g. there is no need to write "PC: 0000" explicitly. A0 is the accumulator (registers A1-A3, also serving as shadow accumulators, are to be added in future versions of the machine). CT is the step counter, for the time being only relevant for the emulator.

PC : FFFF

A0 : FFFFFFFF

CT : FFFFFFFF

0000: FFFF

0001: FFFF

# ...

To save the current state of the machine, run the [save script](https://github.com/yoelmatveyev/Izhora/blob/main/Golly/scripts/izhora_save.py).

# Basic usage of the assembler and emulator

The emulator has been tested under Debian Linux (Bullseye), compiled under SBCL. Some problems encountered were related to SDL (lispbuilder-sdl). It may not show the machine's display correctly (or at all) under another OS or another Common Lisp implementation.

>(defparameter machine (make-izhora)) ; Create an empty machine 

>(asm-compile-file-to-machine "whatever.s" machine) ; Compile an assembly file

>(save-machine machine "whatever") ; Save the machine's state, the extension .izh is automatically added

>(step-program machine 100) ; Run the machine by 100 steps, by 1 step if the second parameter is omitted.

>(display-run machine :speed 1000) ; Run with the display, 1000 steps per frame (1 by default)

>(print-machine machine) ; Print the machine's state in the REPL, zero values are omitted

>(load-machine machine) ; Load a raw .izh file

# Assembler

The assembler follows (more or less) the GNU gas syntax. The following directives are supported:


.stdmacros # Include standard macrocommands

.stdvars # Include standard variables

.global _label #To set the PC 

.org

.word

The standard variables are written by default at 0x0000 (may be overwritten by an .org):

=0 # 0

=1 # 1

=16 # 16

=32 # 32

TMP0 - TMP7 and SYS0 - SYS3 are reserved for temporary data and preset to 0.

The basic instruction, SUBLEQ, may also be written as  S, SUBLEQ2, S2, SBLQ or -?.

The following macrocommands are supported:

ZERO $a # Set A to 0

MOVN $a, $b # Move the 0-a to b; note that unlike the i686 instruction set, the **opposite** arithmetic value is moved.

MOVE $a, $b

SUB $a, $b

ADD $a, $b

JMP $l

The assembler is work in progress and is likely to contain various bugs. See working examples, which include:

Versions of "Hello World" using direct and indexed addressing

128-bit factorials (using a carry propagated between 4 variables)

Primes (using a primitive repetitive substraction loop, skipping even numbers)

Fibonacci numbers
