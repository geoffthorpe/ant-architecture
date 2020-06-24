    lc r4, 0xfffff90a
    lc r5, 0xffff8000
    gtu r6, r4, r5
    halt

#@expected values
#r4 = 0xfffff90a
#r5 = 0xffff8000
#r6 = 0x00000001
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

