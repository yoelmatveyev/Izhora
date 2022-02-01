# Copyright by Yoel Matveyev, 2021
# The GNU General Public License v3.0

# Script for attaching a real keyboard to an Izhora machine (models with a keyboard)

import golly as g

# ESC - F12
# Backspace - F11

# F7 - toggle fullscreen
# F8 - toggle smartscale
# F9  - decrease the current step exponent
# F10 - increase the current step exponent

wait = 64 # How often we're going to scan the keyboard, the bigger number the slower, minimum is 1

run_cycle= 6144 * wait

izhora_keyboard_table = {'f12': [14980, 2456, "none"],'`': [15031, 2456, "none"],'\\': [15082, 2456, "none"],'f1': [15133, 2456, "none"],
                         'f2': [15184, 2456, "none"],'f3': [15235, 2456, "none"],'f4': [15286, 2456, "none"],'f5': [15337, 2456, "none"],
                         'f6': [15388, 2456, "none"],'insert': [15439, 2456, "none"],'delete': [15490, 2456, "none"],'f11': [15541, 2456, "none"],
                         '1': [15004, 2508, "none"],'2': [15055, 2508, "none"],'3': [15106, 2508, "none"],'4': [15157, 2508, "none"],'5': [15208, 2508, "none"],
                         '6': [15259, 2508, "none"],'7': [15310, 2508, "none"],'8': [15361, 2508, "none"],'9': [15412, 2508, "none"],'0': [15463, 2508, "none"],
                         '-': [15514, 2508, "none"],'=': [15565, 2508, "none"],'return': [15616, 2508, "none"],'q': [14980, 2560, "none"],
                         'w': [15031, 2560, "none"],'e': [15082, 2560, "none"],'r': [15133, 2560, "none"],'t': [15184, 2560, "none"],
                         'y': [15235, 2560, "none"],'u': [15286, 2560, "none"],'i': [15337, 2560, "none"],'o': [15388, 2560, "none"],
                         'p': [15439, 2560, "none"],'[': [15490, 2560, "none"],']': [15541, 2560, "none"],'up': [15592, 2560, "none"],
                         'a': [15004, 2612, "none"],'s': [15055, 2612, "none"],'d': [15106, 2612, "none"], 'f': [15157, 2612, "none"],
                         'g': [15208, 2612, "none"],'h': [15259, 2612, "none"],'j': [15310, 2612, "none"],'k': [15361, 2612, "none"],
                         'l': [15412, 2612, "none"],';': [15463, 2612, "none"],'\'': [15514, 2612, "none"],'left': [15565, 2612, "none"],
                         'right': [15616, 2612, "none"],'z': [15031, 2664, "none"],'x': [15082, 2664, "none"],'c': [15133, 2664, "none"],
                         'v': [15184, 2664, "none"],'b': [15235, 2664, "none"],'n': [15286, 2664, "none"],'m': [15337, 2664, "none"],
                         ',': [15388, 2664, "none"],'.': [15439, 2664, "none"],'/': [15490, 2664, "none"],'space': [15541, 2664, "none"],'down': [15592, 2664, "none"],
# Keys with an implicit shift
                         '~': [15031, 2456, "shift"],'!': [15004, 2508, "shift"],'@': [15055, 2508, "shift"],
                         '#': [15106, 2508, "shift"],'$': [15157, 2508, "shift"],'%': [15208, 2508, "shift"],
                         '^': [15259, 2508, "shift"],'&': [15310, 2508, "shift"],'*': [15361, 2508, "shift"],
                         '(': [15412, 2508, "shift"],')': [15463, 2508, "shift"],'_': [15514, 2508, "shift"],
                         '+': [15565, 2508, "shift"],'Q': [14980, 2560, "shift"],'W': [15031, 2560, "shift"],
                         'E': [15082, 2560, "shift"],'R': [15133, 2560, "shift"],'T': [15184, 2560, "shift"],
                         'Y': [15235, 2560, "shift"],'U': [15286, 2560, "shift"],'I': [15337, 2560, "shift"],
                         'O': [15388, 2560, "shift"],'P': [15439, 2560, "shift"],'{': [15490, 2560, "shift"],
                         '}': [15541, 2560, "shift"],'A': [15004, 2612, "shift"],'S': [15055, 2612, "shift"],
                         'D': [15106, 2612, "shift"],'F': [15157, 2612, "shift"],'G': [15208, 2612, "shift"],
                         'H': [15259, 2612, "shift"],'J': [15310, 2612, "shift"],'K': [15361, 2612, "shift"],
                         'L': [15412, 2612, "shift"],':': [15463, 2612, "shift"],'"': [15514, 2612, "shift"],'|': [15082, 2456, "shift"],
                         'Z': [15031, 2664, "shift"],'X': [15082, 2664, "shift"],'C': [15133, 2664, "shift"],
                         'V': [15184, 2664, "shift"],'B': [15235, 2664, "shift"],'N': [15286, 2664, "shift"],
                         'M': [15337, 2664, "shift"],'<': [15388, 2664, "shift"],'>': [15439, 2664, "shift"],
                         '?': [15490, 2664, "shift"]}

def draw_key_dots(event):
    if (event.split()[0] == "key"):
        if (event.split()[1] == "f7"):
            g.setoption("fullscreen", 1 - g.getoption("fullscreen"))
        elif (event.split()[1] == "f8"):
            g.setoption("smartscale", 1 - g.getoption("smartscale"))
        elif (event.split()[1] == "f9"):
            g.setstep(g.getstep() - 1)
        elif (event.split()[1] == "f10"):
            g.setstep(g.getstep() + 1)
        else:
            key = izhora_keyboard_table.get(event.split()[1])
            mod = event.split()[2]
            if key:
                g.setcell(key[0],key[1],1) 
            if (mod == "shift") or (key[2] == "shift"):
                g.setcell(14980,2664,1)
            elif (mod == "ctrl"):
                g.setcell(15592,2456,1)
            elif (mod == "ctrlshift") or ((mod == "ctrl") and (key[2] == "shift")):
                g.setcell(14980,2664,1)
                g.setcell(15592,2456,1)

while (True):
    event = g.getevent()
    if len(event)>1:
        if (event.split()[0] == "key"):
            draw_key_dots(event)
    g.run(run_cycle)
    g.update()
