    lc r4, 0x00000001
    lc r5, 0x00000010
    lc r6, 0x80000020
    bez r10, r4, r5
    lc r7, 0xdeadbeef
    halt
    lc r8, 0xdeadbeef
    halt

#@expected values
#r4 = 0x00000001
#r5 = 0x00000010
#r6 = 0x80000020
#r7 = 0xdeadbeef
#pc = 2147483680
