# $Id: 14_beq_2.asm,v 1.2 2001/03/22 00:39:04 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test of beq.
# OK

	lc r2, $eq
	beq r2, r2, r0

	add r4, r1, r0
	hlt

eq:
	lc r3, 10
	hlt
