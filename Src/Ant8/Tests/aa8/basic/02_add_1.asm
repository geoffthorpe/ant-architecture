# $Id: 02_add_1.asm,v 1.3 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests add
# OK

	lc r2, 1
	add r3, r2, r2
	add r4, r3, r2
	add r5, r4, r2
	add r6, r5, r2
	add r7, r6, r2
	add r8, r7, r2
	add r9, r8, r2
	add r10, r9, r2
	add r11, r10, r2
	add r12, r11, r2
	add r13, r12, r2
	add r14, r13, r2
	add r15, r14, r2

	hlt
