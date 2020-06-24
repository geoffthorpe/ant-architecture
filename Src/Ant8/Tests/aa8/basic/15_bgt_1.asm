# $Id: 15_bgt_1.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test of bgt.
# OK

	lc r2, $gt
	bgt r2, r0, r0

	add r4, r1, r0
	hlt

gt:
	lc r3, 10
	hlt
