# $Id: squares.asm,v 1.2 2000/11/22 00:29:59 ellard Exp $
# Barney Titmouse - 11/10/96
#
# Prints numbers 0 through 10, and their squares.
#

	lc	r2, 0
	lc	r3, 10

loop:
	sys	r2, 0x2

	lc	r5, ' '
	sys	r5, 0x3

	mul	r5, r2, r2
	sys	r5, 0x2

	lc	r5, '\n'
	sys	r5, 0x3

	lc	r5, $end
	beq	r5, r2, r3

	inc	r2, 1
	jmp	$loop

end:
	sys	r0, 0x0

# end of squares.asm
