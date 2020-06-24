# $Id: 05_mul_3.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests mul, with overflow.
# OK

	lc r2, -100
	mul r3, r2, r2
	add r4, r1, r0

	lc r5, 100
	mul r6, r5, r5
	add r7, r1, r0

	lc r8, -128
	lc r9, -1
	mul r10, r8, r9
	add r11, r1, r0

	mul r12, r9, r9
	add r13, r1, r0

	mul r14, r8, r8
	add r15, r1, r0

	hlt

