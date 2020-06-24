# $Id: 10_ld_5.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ Tests that ld1 can use r0 and r1 as addresses.
#@ Doesn't really do much, except that the right values
#@ are loaded and the instructions don't fault.
# OK

	lc r2, $_data_

	nor r0, r2, r2		# copies r2 into r1.
	ld r6, r1, 0

	hlt

_data_:

	.byte	30, 31, 32, 33, 34, 35, 36, 37
