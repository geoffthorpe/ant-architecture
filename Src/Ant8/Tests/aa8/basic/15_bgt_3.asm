# $Id: 15_bgt_3.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test of bgt.
# OK

	lc r2, $gt
	lc r4, 10
	lc r3, 11

	bgt r2, r4, r3
	add r5, r1, r0

	hlt

gt:
	lc r6, 10
	hlt

