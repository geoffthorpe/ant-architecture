    lc r4, 0x80000001
    lc r5, 0x80000000
    eq r6, r4, r5
    halt

#@expected values
#r4 = 0x80000001
#r5 = 0x80000000
#r6 = 0x00000000
#pc = -2147483624
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

