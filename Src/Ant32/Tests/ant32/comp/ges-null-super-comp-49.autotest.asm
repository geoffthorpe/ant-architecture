    lc r4, 0x00000002
    lc r5, 0xfffffffd
    ges r6, r4, r5
    halt

#@expected values
#r4 = 0x00000002
#r5 = 0xfffffffd
#r6 = 0x00000001
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

