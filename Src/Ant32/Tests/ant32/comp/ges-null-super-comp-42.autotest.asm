    lc r4, 0xfffffffe
    lc r5, 0x00000001
    ges r6, r4, r5
    halt

#@expected values
#r4 = 0xfffffffe
#r5 = 0x00000001
#r6 = 0x00000000
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

