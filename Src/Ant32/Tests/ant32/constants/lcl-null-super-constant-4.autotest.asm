    lcl r5, 1
    lcl r5, 0xffff
    halt

#@expected values
#r5 = 0xffffffff
#pc = 0x8000000c
#e0 = 0
#e3 = 0

