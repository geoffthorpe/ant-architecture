	lc      r40, 0x80000048
	leh     r40
	lc      r46, 0x54 #address
	lc      r47, 0          #interrupts on
	lc      r48, 1          #in user mode
	lc      r42, 0x0000000d #denotes VPN 0 is fetchable, readable,
	lc      r43, 0x00000000 #denotes VPN 0 maps to physical page 0
	tlbse   r0, r42         #load into entry 0
	lc      r42, 0x0000101e #denotes VPN 1 is readable, writable,
	lc      r43, 0x00001000 #denotes VPN 1 maps to physical page 2
	tlbse   r48, r42        #load into entry 1
	lc      r44, 2          #load into TLB entry 2
	lc      r42, 0x3fffe01e #denotes VPN 0x3ffff is readable, writable,
	lc      r43, 0xffffe000 #map VPN 0x3fffe to page 0xffffe
	tlbse   r44, r42
	rfe     r46, r47, r48
	lc	r49, 0x11112222
	halt    #or rather don't =)
	lc      r50, 0x33334444

	trap

