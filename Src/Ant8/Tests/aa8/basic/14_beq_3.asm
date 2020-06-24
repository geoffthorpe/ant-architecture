# $Id: 14_beq_3.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test of beq.
# OK

	lc r2, $eq
	lc r3, 10
	lc r4, 10
	beq r2, r3, r4

	hlt

eq:
	add r5, r1, r0
	lc r6, 10
	hlt
