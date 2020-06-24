# $Id: 04_sub_r1.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ test sub with r1
# OK

	lc r2, -100
	lc r3, 100

	sub r1, r2, r3
	add r5, r1, r0

	hlt
