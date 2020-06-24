    lcl r5, 0xffff
    lcl r5, 1
    halt

#@expected values
#r5 = 1
#pc = 0x8000000c
#e0 = 0
#e3 = 0

