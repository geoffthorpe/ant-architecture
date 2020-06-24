    lc r4, 0x0000006d
    lc r5, 0x00008000
    gtu r6, r4, r5
    halt

#@expected values
#r4 = 0x0000006d
#r5 = 0x00008000
#r6 = 0x00000000
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

