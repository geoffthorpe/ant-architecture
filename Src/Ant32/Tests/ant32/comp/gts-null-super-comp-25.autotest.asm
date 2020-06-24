    lc r4, 0x7fffffff
    lc r5, 0x80000000
    gts r6, r4, r5
    halt

#@expected values
#r4 = 0x7fffffff
#r5 = 0x80000000
#r6 = 0x00000001
#pc = -2147483624
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

