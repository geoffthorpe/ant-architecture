    lc r4, 0x80000020
    leh r4
    cle
    div r0, r0, r0
    lc r5, 0xdeadbeef
    halt
    lc r6, 0xdeadbeef
    halt

#@expected values
#r4 = 0x80000020
#r6 = 0xdeadbeef
#pc = 0x8000002c
#e0 = 0x80000010
#e3 = 0x00000071

