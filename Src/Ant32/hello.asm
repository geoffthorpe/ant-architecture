# $Id: hello.asm,v 1.2 2001/02/21 12:39:41 ellard Exp $
#
# Copyright 2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# A simple "hello world" program.

	lc	r2, $hello
loop:
	ld1	r3, r2, 0
	jezi	r3, $end_loop
	cout	r3
	addi	r2, r2, 1
	j	$loop
end_loop:
	halt

_data_:

hello:
	.word 0x41424344
	.byte 'h', 'e', 'l', 'l', 'o', ',', ' '
	.byte 'w', 'o', 'r', 'l', 'd', '!', '\n'
	.byte 0

