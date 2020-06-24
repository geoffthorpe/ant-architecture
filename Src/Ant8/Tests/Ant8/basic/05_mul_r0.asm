# $Id: 05_mul_r0.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests mul with r0
# OK

	lc r2, -100
	lc r3, 100

	mul r0, r2, r3
	add r5, r1, r0

	hlt

