# $Id: 15_bgt_5.asm,v 1.2 2001/03/22 00:39:04 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test of bgt.
# OK

	lc r2, $gt
	lc r3, -11
	lc r4, -10

	bgt r2, r4, r3

	lc r5, 10
	hlt

gt:
	add r6, r1, r0
	hlt
