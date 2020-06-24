    lcl r5, 0xffff
    lch r5, 0x1234
    halt

#@expected values
#r5 = 0x1234ffff
#pc = 0x8000000c
#e0 = 0
#e3 = 0

