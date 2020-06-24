    lc r4, 0xffffff80
    lc r5, 0xfffc4a71
    geu r6, r4, r5
    halt

#@expected values
#r4 = 0xffffff80
#r5 = 0xfffc4a71
#r6 = 0x00000001
#pc = -2147483628
#e0 = 0
#e1 = 0
#e2 = 0
#e3 = 0

