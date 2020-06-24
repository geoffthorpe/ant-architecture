    lc r4, 0x00000001
    lc r5, 0x00000010
    lc r6, 0x80000020
    jez r10, r0, r6
    lc r7, 0xdeadbeef
    halt
    lc r8, 0xdeadbeef
    halt

#@expected values
#r4 = 0x00000001
#r5 = 0x00000010
#r6 = 0x80000020
#r8 = 0xdeadbeef
#pc = 0x8000002c

