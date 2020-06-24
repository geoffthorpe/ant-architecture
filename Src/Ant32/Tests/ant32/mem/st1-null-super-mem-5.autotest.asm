    lc r4, 0x00000000
    lc r5, 0x0000101f
    lc r6, 0x00000000
    tlbse r6, r4
    lc r8, 0x40000000
    lc r9, 0x0000101f
    lc r10, 0x00000001
    tlbse r10, r8
    lc r11, 0xdeadbeef
    lc r12, 0x3fffffff
    lc r13, 0x3fffffff
    st1 r11, r13, 2
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
#r12 = 0x3fffffff
#r13 = 0x3fffffff
#mem 0x00001001 = ef
#pc = 0x80000044

