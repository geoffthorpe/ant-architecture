# add_func.asm
# An Ant-32 function to compute the sum of two numbers.

main:
	# Set up the stack and frame pointers.  (This is usually done
	# by the executive, but this is included here in order to make
	# this example stand-alone.)

	lc	sp, 0x80002000
	lc	fp, 0x80002000

	lc	g1, 0x20
	lc	g2, 0x30
	push	g1
	push	g2
	call	$add
	pop	ze
	pop	ze

	halt

#

add:
	entry	0
	ld4	g3, fp, 8	# g3 gets a copy of B
	ld4	g4, fp, 12	# g4 gets a copy of A
	add	g0, g3, g4
	return	g0

