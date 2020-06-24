    lc r4, 0x00000002
    lc r5, 0x00000003
    geu r6, r4, r5
    halt

#@expected values
#r4 = 0x00000002
#r5 = 0x00000003
#r6 = 0x00000000
#pc = -2147483632
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

