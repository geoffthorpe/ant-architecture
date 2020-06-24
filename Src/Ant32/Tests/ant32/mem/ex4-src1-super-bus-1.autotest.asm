#load exception handler
    lc      r40, 0x8000002c
    leh     r40

#enable exceptions
	cle

#load junk tlb entry for memory tests
    lc      r44, 2          #load into TLB entry 2
    lc      r42, 0x3fffe000 #denotes VPN 0x3ffff
    lc      r43, 0x3fffe01f #map VPN 0x3fffe to page 0xffffe
							#and is readable, writable, valid, and dirty
                            #(dirty to prevent taking a
                            #read-only exception)
    tlbse   r44, r42

#go to the generated code
	bezi	r0, 4

#handle exceptions
    lc  r49, 0xdeadbeef
    halt    #or rather don't =)


#actual testcode:
    lc r30, 0x3fffef00
    lc r32, 0
    ex4 r32, r30, 0
    halt

#@expected values
#mode = S
#interrupts = off
#exceptions = off
#pc = 0x80000038#e0 = 0x80000044#e3 = 0x00000039

