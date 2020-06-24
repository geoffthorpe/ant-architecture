# $Id: 13_jmp_1.asm,v 1.3 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ A test of jmp.
# OK


a:	jmp $b
b:	add r2, r1, r0

c:	jmp $d
	lc r3, 1		# this shouldn't get set.

d:	add r4, r1, r0
	jmp $e

	# Just a bunch of meaningless instructions,
	# to make sure that we can jump to high addresses.

	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0
	add r2, r0, r0

	# We're not meant to get here!

	hlt

	# Instead, we should arrive here.

e:	add r5, r1, r0
	lc r6, 10

	hlt
