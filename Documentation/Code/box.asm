# $Id: box.asm,v 1.2 2000/11/22 00:29:59 ellard Exp $
#
# Barney Titmouse - cs50 1997
#
# box - draw a box of asterixes on the screen.
#
# Register usage:
#
# r2 - the size of the box.
# r3 - outer loop counter.
# r4 - inner loop counter.
# r5 - used to hold label addresses for branching.
# r6 - used to hold the contstant '*'.

	lc r6, '*'
	lc r7, '\n'

	sys r2, 5

	lc r3, 1
outer_loop:
	lc r5, $end_outer_loop
	bgt r5, r3, r2

	lc r4, 1
inner_loop:
	lc r5, $end_inner_loop
	bgt r5, r4, r2

	sys r6, 3
	inc r4, 1
	jmp $inner_loop

end_inner_loop:
	sys r7, 3
	inc r3, 1
	jmp $outer_loop

end_outer_loop:

	sys r0, 0

# end of box.asm
