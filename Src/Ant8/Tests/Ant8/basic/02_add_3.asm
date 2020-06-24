# $Id: 02_add_3.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests add with overflow.
# OK

	lc r2, 100
	add r3, r2, r2
	add r4, r1, r0

	add r5, r3, r3
	add r6, r1, r0

	add r7, r5, r5
	add r8, r1, r0

	add r9, r7, r7
	add r10, r1, r0

	add r11, r9, r9
	add r12, r1, r0

	add r13, r11, r11
	add r14, r1, r0

	hlt

