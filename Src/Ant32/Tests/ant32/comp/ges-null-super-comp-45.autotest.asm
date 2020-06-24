    lc r4, 0x7fffffff
    lc r5, 0x00000002
    ges r6, r4, r5
    halt

#@expected values
#r4 = 0x7fffffff
#r5 = 0x00000002
#r6 = 0x00000001
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

