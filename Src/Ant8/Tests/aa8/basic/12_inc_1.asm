# $Id: 12_inc_1.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ testing inc.
# OK

	lc r2, 0
	inc r2, 127
	add r3, r1, r0

	lc r4, 0
	inc r4, -128
	add r5, r1, r0

	lc r6, 100
	inc r6, 100
	add r7, r1, r0

	lc r8, -100
	inc r8, 100
	add r9, r1, r0

	lc r10, -100
	inc r10, 100
	add r11, r1, r0

	lc r12, -100
	inc r12, -100
	add r13, r1, r0

	hlt

