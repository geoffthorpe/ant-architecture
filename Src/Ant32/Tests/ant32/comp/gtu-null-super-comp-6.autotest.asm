    lc r4, 0xffff8000
    lc r5, 0xfffff90a
    gtu r6, r4, r5
    halt

#@expected values
#r4 = 0xffff8000
#r5 = 0xfffff90a
#r6 = 0x00000000
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

