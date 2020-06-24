    lc r4, 0x00000000
    lc r5, 0x0000101f
    lc r6, 0x00000000
    tlbse r6, r4
    lc r8, 0x40000000
    lc r9, 0x0000101f
    lc r10, 0x00000001
    tlbse r10, r8
    lc r11, 0xdeadbeef
    lc r12, 0x40000000
    lc r13, 0x40000000
    st4 r11, r12, 0
    ld4 r30, r12, 0
    halt

#@expected values
#r4 = 0x00000000
#r5 = 0x0000101f
#r6 = 0x00000000
#tlb 0:
#    vpn = 0x00000
#    os = 0x000
#    ppn = 0x00001
#    at = 0x01f
#r8 = 0x40000000
#r9 = 0x0000101f
#r10 = 0x00000001
#tlb 1:
#    vpn = 0x40000
#    os = 0x000
#    ppn = 0x00001
#    at = 0x01f
#r11 = 0xdeadbeef
#r12 = 0x40000000
#r13 = 0x40000000
#mem 0x00001000 = 0xef
#mem 0x00001001 = 0xbe
#mem 0x00001002 = 0xad
#mem 0x00001003 = 0xde
#r30 = 0xdeadbeef
#pc = 0x80000048

