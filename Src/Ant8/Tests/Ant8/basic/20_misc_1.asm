# $Id: 20_misc_1.asm,v 1.2 2001/03/22 00:39:04 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests that r1 is zero'd when things go right.
#@ this test won't diagnose the problem correctly if lc/add/inc
#@ are not working mostly properly...

	lc r2, 100
	inc r2, 100		# generate an overflow
	add r3, r1, r0		# save the overflow
	add r4, r1, r0		# but no overflow here!

	lc r5, -100
	inc r5, -100		# generate an underflow
	add r6, r1, r0		# save the underflow
	add r7, r1, r0		# but no underflow here!

	hlt
