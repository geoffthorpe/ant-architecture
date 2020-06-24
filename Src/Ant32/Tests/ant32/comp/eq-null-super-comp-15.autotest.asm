    lc r4, 0x0040e5aa
    lc r5, 0x00000001
    eq r6, r4, r5
    halt

#@expected values
#r4 = 0x0040e5aa
#r5 = 0x00000001
#r6 = 0x00000000
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

