# Copyright by Yoel Matveyev, 2021
# The GNU General Public License v3.0

import sys
import golly as g

# Check for the wire cell that blocks the gun in the script control counter

if g.getcell(16700,6902) != 3:
    raise TypeError("Hm, is this an Izhora machine? Apparently not!")

# Wait until the end of a CPU cycle and block the next one

def stop_machine():
    while g.getcell(13132,7265) == 0:
        g.run(1)
        if g.getcell(13132,7265) == 1:
            g.setcell(13176,7346,3)
            g.setcell(13176,7353,3)
 
# Remove the block, send a photon to initiate a new CPU cycle

def restart_machine():
    g.setcell(13176,7346,0)
    g.setcell(13176,7353,0)
    g.setcell(13128,7259,1)
    g.setcell(13129,7259,1)
    g.setcell(13128,7260,2)
    g.setcell(13129,7260,2)
        
program = [0]*0x10000
a0 = 0
pc = 0

# Default position of the lowest bit at #0000

bx = 12868
by = 6996

# Memory segment size

mx = 121
my = 131

# Address position

adx = 13063
ady = 7284

# A0 position

a0x = 13416
a0y = 7338

# Check the nth bit in an integer

def nth_bit(x,n):
    return x & 1 << n != 0

# Set a bit in the image list

def read_bit(x,y,n,program):
    program[x*0x800+y*0x40+n//32] += 1 << n%32

filename = g.savedialog("Name of your Izhora image:")

# Download the RAM contents bit by bit
                
def read_ram(program):
    for t in range(0,6144):
        for x in range(0,32):
            for y in range(0,32):
                offset=(t-x*mx-y*my)%6144
                if offset % 3 == 0:
                    if g.getcell(bx+x*mx,by-y*my) != 0:
                        read_bit(x,y,offset // 3,program)
        g.run(1)
                
# Red the accumulator and the address set for the next read cycle

def read_reg():
    for x in range(0,16):
            if g.getcell(adx-x*10,ady) == 0:
                pc += 1 << x
    for x in range(0,32):
            if g.getcell(a0x+x*10,a0y) == 0:
                a0 += 1 << x

def write_image(program,pc,a0):
    original_stdout = sys.stdout
    with open(filename, "w") as file:
        sys.stdout = file
        if pc != 0:
            print ("PC: ",pc)
        if a0 != 0:
            print ("A0: ",a0)
        for addr,data in enumerate(program):
            if data > 0:
                print ("{0:0{1}X}".format(addr,4),
                       "{0:0{1}X}".format(data,8))
    sys.stdout = original_stdout

old_step=g.getstep()
g.setstep(0)

stop_machine()

# Run until synchronized with read_ram()

while g.getcell(16700,6900) != 1:
    g.run(1)
    
read_ram(program)
read_reg()
write_image(program,pc,a0)
restart_machine()

g.setstep(old_step)
