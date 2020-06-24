    lc r4, 0x00008000
    lc r5, 0x0000006d
    ges r6, r4, r5
    halt

#@expected values
#r4 = 0x00008000
#r5 = 0x0000006d
#r6 = 0x00000001
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

