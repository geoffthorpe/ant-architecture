# $Id: 12_inc_2.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ testing inc, with overflow
# OK

	lc r2, 127
	inc r2, 1
	add r3, r1, r0

	lc r4, 127
	inc r4, 2
	add r5, r1, r0

	lc r6, 127
	inc r6, -1
	add r7, r1, r0

	lc r8, 127
	inc r8, -2
	add r9, r1, r0

	lc r10, -128
	inc r10, 1
	add r11, r1, r0

	lc r12, -128
	inc r12, 2
	add r13, r1, r0

	lc r14, -128
	inc r14, -1
	add r15, r1, r0

	hlt

