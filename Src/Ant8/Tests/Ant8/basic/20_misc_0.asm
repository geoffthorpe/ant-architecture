# $Id: 20_misc_0.asm,v 1.2 2001/03/22 00:39:04 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests that r1 is zero'd when things go right.
#@ this test won't diagnose the problem correctly if lc/add/sub
#@ are not working mostly properly...

	lc r2, 100
	lc r3, 100
	add r4, r2, r3		# generate an overflow
	add r5, r0, r1		# and save it.  Now the overflow should be gone.
	add r6, r0, r1		# r6 should get zero.

	lc r15, 1
	add r7, r2, r3		# generate an overflow
	add r8, r2, r15		# but no overflow here!
	add r9, r0, r1		# r9 should also get zero.

	# Now we run through the same drill, with sub instead of add.

	lc r2, 100
	lc r3, -100
	sub r10, r2, r3		# generate an overflow
	add r11, r0, r1		# and save it.  Now the overflow should be gone.
	add r12, r0, r1		# r12 should get zero.

	lc r15, 1
	sub r13, r2, r3		# generate an overflow
	add r14, r2, r15	# but no overflow here!
	add r15, r0, r1		# r15 should also get zero.

	hlt
