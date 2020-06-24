# $Id: 09_shf_4.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test shf
# OK

	lc r2, 1
	lc r3, 2
	lc r4, 3
	lc r5, -3
	lc r6, -2
	lc r7, -1

	shf r2, r2, r2
	add r8, r1, r0

	shf r3, r3, r3
	add r9, r1, r0

	shf r4, r4, r4
	add r10, r1, r0

	shf r5, r5, r5
	add r11, r1, r0

	shf r6, r6, r6
	add r12, r1, r0

	shf r7, r7, r7
	add r13, r1, r0

	lc r14, 1
	shf r15, r14, r0

	hlt
