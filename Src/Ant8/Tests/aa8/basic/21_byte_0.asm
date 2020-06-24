# $Id: 21_byte_0.asm,v 1.2 2001/03/22 00:39:00 ellard Exp $
#
# Copyright 1999-2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# tests _data_ and .byte

	lc	r2, 1	# Just so _data_ starts somewhere non-zero.
	lc	r3, 2

	hlt

_data_:

	.byte	0, 1, 2, 3
	.byte	0x0, 0x1, 0x2, 0x3
	.byte	00, 01, 02, 03
	.byte	0b0, 0b1, 0b10, 0b11
	.byte	'0', '1', '2', '3'
	.byte	'\n', '\\', '\t', '\0'
	.byte	'#', '#', '#', '#'	# comment starts here!
	.byte	0, 1, 2, 3
	.byte	$_data_, $_data_

