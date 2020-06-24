    lc r4, 0xffffffff
    lc r5, 0x80000001
    gts r6, r4, r5
    halt

#@expected values
#r4 = 0xffffffff
#r5 = 0x80000001
#r6 = 0x00000001
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

