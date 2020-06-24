# $Id: 02.asm,v 1.1 2001/03/22 21:31:40 ellard Exp $
#@ Tests the 'd' command, and a little st1.

	lc	r2, 1
	lc	r3, 2
	lc	r4, $_data_

store1:
	st	r2, r4, 0
	st	r3, r4, 1

store2:
	st	r2, r4, 2
	st	r3, r4, 3

	hlt
_data_:
	.byte	0xff, 0xff, 0x0, 0x0
	.byte	0xff, 0xff, 0x0, 0x0
end_data:

#>> b $store1, $store2
#>> d $_data_
#>> p
#>> r
#>> p
#>> d $_data_, $end_data
#>> g
#>> d $_data_, $end_data
#>> g
#>> d $_data_, $end_data
#>> d
#>> q
