# $Id: 05_mul_2.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests mul, with overflow.
# OK

	lc r2, 100
	mul r3, r2, r2
	add r4, r1, r0

	mul r5, r3, r3
	add r6, r1, r0

	mul r7, r5, r5
	add r8, r1, r0

	mul r9, r7, r7
	add r10, r1, r0

	mul r11, r9, r9
	add r12, r1, r0

	mul r13, r11, r11
	add r14, r1, r0

	hlt

