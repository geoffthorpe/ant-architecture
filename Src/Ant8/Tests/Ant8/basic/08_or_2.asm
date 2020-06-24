# $Id: 08_or_2.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests bitwise NOR
# OK

	lc r2, 0b11100100
	lc r3, 0b00011011
	lc r4, 0b10101010
	lc r5, 0b01010101

	nor r2, r2, r3
	add r7, r1, r0

	nor r5, r3, r5
	add r8, r1, r0

	lc r9,	0b11100100
	lc r10, 0b11001010

	nor r9, r9, r9
	nor r10, r1, r1
	nor r11, r1, r0

	hlt
