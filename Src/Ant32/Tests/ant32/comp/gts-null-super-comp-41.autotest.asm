    lc r4, 0x00000001
    lc r5, 0xfffffffe
    gts r6, r4, r5
    halt

#@expected values
#r4 = 0x00000001
#r5 = 0xfffffffe
#r6 = 0x00000001
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

