# $Id: 09_shf_2.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests bitwise SHIFT
# OK

	lc r2, 0b00010001
	lc r3, 0b11101110
	lc r4, 2
	lc r5, -2

	shf r6, r2, r4
	add r7, r1, r0

	shf r8, r2, r5
	add r9, r1, r0

	shf r10, r3, r4
	add r11, r1, r0

	shf r12, r3, r5
	add r13, r1, r0

	hlt
