# Izhora
Izhora is a fully operational universal computer build as a large pattern constructed in Fireworld2, a simple 4-state cellular automation rule invented by me (Yoel Matveyev) in 2020. In turn, Fireworld2 is based on Fireworld, a very simple 3-state cellular automation I have discovered in 2001. Fireworld has be proven (by me) to be Turing-complete; however, it lacks stable reflectors and splitters, which makes circuitry construction very tedious due to timing issues. Fireworld2 is a natural superset of Fireworld with an additional wiring state. "Electrons", i.e. signals bound to the wires, run on top of immutable wire structures. I would like to thank Brian Prentice for giving me inspiration by his rule Wilfred invented as a superset of Brian's Brain - a well known rule proven (also by me) to be Turing-complete. Soon after the invention of Fireworld2 I discovered that it's surprisingly suitable for computation. Simple constuctions act naturally as logic gates, reflectors and splitters,  stable bit registers, flip-flops, signal generators etc. All this gives a tremendous enhancement to the computational usability of the original Fireworld and largely eliminates the timing difficulties.

In 2017 I wrote a simple virtual machine, which uses balanced ternary logic instead of binary. It's called Nutes, the reverse of Setun, a historical Soviet computer notable for being the only ternary mainframe ever created. Setun is a river in outskirts of Moscow. Izhora is a river in outskirts of St. Petersburg, named after an ancient Finno-Ugric tribe.

The current basic version of the computer, Izhora 1, has 256k of 32-bit word-addressable XOR-writable RAM, a 32-bit accumulator, a 16-bit program counter and a 128x64 graphic display. It has only one operation: a variety of Subleq known to be Turing-complete. On each cycle, the CPU reads a 32-bit word from the RAM and interprets its 16 highest bits and an absolute jump address and the lowest 16 bits as an operand address. The accumulator is them subtracted from the operand; the result is stored in both the accumulator and the operand. If the result was zero or negative, the CPU branches to the jump address; otherwise it proceeds to the next instruction.

As simple as it is, Subleq systems are known to be practical. There is even a full-fledged OS with a C-like compiler written for an emulated 64-bit Subleq computer; it's called Dawn OS.

The RAM has a NUMA architecture. Cells located close to the CPU are accessed about 4 times faster than the furthest ones. The display memory starts at #0400. Note that since the machine was 32-bit addressing, #100 means 1024, not 256 bytes. The lowest 4k of the memory should be used for common library functions and variables.

The Izhora emulator, written in Common Lisp, is currently in pre-alpha stage (usable though). An assembler and Python scripts for coding the actual machine in Golly are yet to be written. Some work has been already done toward a new version of the computer that will have, hopefully, RISC features implemented by mapping some jump addresses to other operations, optional relative addressing mode, several registers with an advanced ALU, and a script-driven emulated keyboard.

Although the computer is fully operational, each operations takes about 40,000 generations on average. Programs longer than 10-20k will inevitably slow down Golly's hashlife algorithm. Don't expect to see more than 10 operations per second. Run the "Hello World" program from this repository and see how it works. The only way to run programs reasonably fast in Golly would be by a custom simulator script yet to be written.
 
