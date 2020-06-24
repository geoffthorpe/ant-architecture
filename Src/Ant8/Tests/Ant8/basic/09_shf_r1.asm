# $Id: 09_shf_r1.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests bitwise SHIFT for r1
# OK

	lc r2, 0b00000001
	lc r3, 0b11111111
	lc r4, 1
	lc r5, -1

	shf r1, r2, r4
	add r7, r1, r0

	hlt
