# $Id: 01_lc_1.asm,v 1.1 2001/03/22 21:31:39 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests lc
# OK

	lc r15, 15
	lc r14, 15
	lc r13, 15
	lc r12, 15
	lc r11, 15
	lc r10, 15
	lc r9, 15
	lc r8, 15
	lc r7, 15
	lc r6, 15
	lc r5, 15
	lc r4, 15
	lc r3, 15
	lc r2, 15
lc_r0:
	lc r0, 15
	lc r1, 15

	hlt

#>> b $lc_r0
#>> r
#>> p
#>> g
#>> p
#>> q
