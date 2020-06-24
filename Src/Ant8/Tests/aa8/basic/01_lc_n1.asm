# $Id: 01_lc_n1.asm,v 1.2 2001/03/22 00:38:59 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests lc, with lots of different formats.

	lc r2, 0
	lc r2, 0x0
	lc r2, 00
	lc r2, 0b0
	lc r2, '\0'
	lc r2, $foo

foo:

	lc r3, 100
	lc r3, 0x10
	lc r3, 010
	lc r3, '\n'

	lc r2, 0b1000000

	hlt
