# $Id: 02_add_4.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests to make sure that des registers don't clobber src.
# OK

	lc r2, 100
	lc r3, 100

	add r2, r2, r3
	add r4, r1, r0
	add r5, r1, r2

	hlt

