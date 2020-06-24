    lc r4, 0xfffffffe
    lc r5, 0x80000000
    gtu r6, r4, r5
    halt

#@expected values
#r4 = 0xfffffffe
#r5 = 0x80000000
#r6 = 0x00000001
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

