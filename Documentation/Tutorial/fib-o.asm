# $Id: fib-o.asm,v 1.4 2002/03/22 16:23:44 ellard Exp $
# Dan Ellard
# An Ant-8 implementation of the recursive fibonacci function.
# Register usage:
# r3 - the return value from the function.
# r4 - the current value to compute fib of
# r5 - scratch for return address
# r6 - scratch
# r15 - the base of the stack

	lc  r15, $stack

	in  r4, Hex	# Read the number...

	jmp $fib
	out r3, Hex
	lc  r3, '\n'
	out r3, ASCII
	hlt

fib:
	add r5, r1, r0	# save return address in r5

	# Handle the base case first:
	lc  r6, 2
	lc  r3, 1
	bgt r5, r6, r4	# if 2 > r4, return 1.

	# Otherwise, we need to do the whole thing.
	# Begin by building the stack frame:

	inc r15, 3	# bump up the stack pointer
	st1 r5, r15, 0	# store return address
	st1 r4, r15, 1	# store parameter.

	# Compute fib (x-1), and save the result
	#	(returned in r3) on the stack.
	inc r4, -1
	jmp $fib
	st1 r3, r15, 2

	# Retrieve the original value of the parameter
	# (which might have been obliterated in a
	# recursive call) and put it back in r4.

	ld1 r4, r15, 1

	# Compute fib (x-2), and leave the result
	#	in register r3.
	inc r4, -2
	jmp $fib

	# Retrieve the previously returned value from
	# the stack, and add it to r3.  Now r3 has the
	# value we want to return.

	ld r6, r15, 2
	add r3, r3, r6

	# Retrieve the return address from the stack,
	# bump the stack pointer down, and return.

	ld1 r5, r15, 0
	inc r15, -3
	beq r5, r0, r0

_data_:

stack:
