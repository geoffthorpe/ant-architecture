    lc r4, 0xfffffffe
    lc r5, 0x7fffffff
    geu r6, r4, r5
    halt

#@expected values
#r4 = 0xfffffffe
#r5 = 0x7fffffff
#r6 = 0x00000000
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

