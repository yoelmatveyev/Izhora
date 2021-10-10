import golly as g

# Check for the wire cell that blocks the gun in the script control counter

if g.getcell(16700,6902) != 3:
    raise TypeError("Hm, is this an Izhora machine? Apparently not!")

program = [0]*0x10000
a0 = 0
pc = 0

# Default position of the lowest bit at #0000

bx = 12868
by = 6996

# Memory segment size

mx = 121
my = 131

# Data position

dx = 13101
dy = 7185

# Address position

adx = 13063
ady = 7284

# A0 position

a0x = 13416
a0y = 7338

# Check the nth bit in an integer

def nth_bit(x,n):
    return x & 1 << n != 0

# Check the nth bit in a 256-byte segment

def nth_bit_seg(x,y,n):
    return nth_bit(program[x*0x800+y*0x40+n//32],n%32)

with open(g.opendialog("Open an Izhora machine image")) as file:
    for line in file:
        if "#" not in line:
            if ":" in line:
                if "A0" in line:
                    a0 = int(line.split(":")[1],16)
                if "PC" in line:
                    pc = int(line.split(":")[1],16)        
            else:
                program[int(line.split(" ")[0],16)] = int(line.split(" ")[1],16)

# Upload a program bit by bit
                
def load_program(program):
    for t in range(0,6144):
        for x in range(0,32):
            for y in range(0,32):
                offset=(t-x*mx-y*my)%6144
                if offset % 3 == 0:
                    if nth_bit_seg(x,y,offset // 3):
                        g.setcell(bx+x*mx,by-y*my,1)
                        g.setcell(bx+x*mx+1,by-y*my,2)
                    else:
                        g.setcell(bx+x*mx,by-y*my,0)
                        g.setcell(bx+x*mx+1,by-y*my,0)
        g.run(1)
    
# Set the accumulator and the address for the initial read cycle

def initiate_machine():
    for x in range(0,32):
        g.setcell(dx-x*10,dy,1)
    for x in range(0,16):
        if nth_bit(pc,x):
            g.setcell(adx-x*10,ady,0)
        else:
            g.setcell(adx-x*10,ady,1)
    for x in range(0,32):
         if nth_bit(a0,x):
            g.setcell(a0x+x*10,a0y,0)
         else:
            g.setcell(a0x+x*10,a0y,1)

# Turn on the machine by sending a photon to emulate a CPU cycle

def start_machine():
    g.setcell(13128,7259,1)
    g.setcell(13129,7259,1)
    g.setcell(13128,7260,2)
    g.setcell(13129,7260,2)

old_step=g.getstep()
g.setstep(0)

# Run until synchronized with an external update

while g.getcell(16700,6900) != 1:
    g.run(1)
    
load_program(program)
initiate_machine()
start_machine()         
                
g.setstep(old_step)
