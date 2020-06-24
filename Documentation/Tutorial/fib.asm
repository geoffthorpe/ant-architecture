# $Id: fib.asm,v 1.9 2002/03/22 16:23:44 ellard Exp $
# Dan Ellard
# An Ant-8 implementation of the recursive fibonacci function.
# Register usage:
# r2  - value to compute the fibonacci number of.
# r14 - the return value from the fib function.
# r15 - the base of the stack

	lc  r15, $stack

	in  r2, Hex	# Read the number...

	jmp $fib
	out r14, Hex
	lc  r14, '\n'
	out r14, ASCII
	hlt

	# Register usage:
	# r2 - argument value.
	# r3 - scratch value.
	# r13 - return address.
	# r14 - return value.
	# r15 - stack pointer.
fib:
	st1 r1, r15, 0		# preserve the return address on the stack
	st1 r2, r15, 1		# preserve the parameter.
	st1 r3, r15, 2		# preserve r3.
	inc r15, 3		# bump the stack pointer down.

	# Handle the base case first:
	lc  r3, 2
	lc  r14, 1
	lc  r13, $fib_return
	bgt r13, r3, r2	# if 2 > r2, return 1.

	# Compute fib (x-1), and save the result
	#	(returned in r14) in register r3.
	inc r2, -1
	jmp $fib
	add r3, r14, r0

	# Compute fib (x-2), and leave the result
	#	in register r14.
	inc r2, -1
	jmp $fib

	# Compute the sum of fib(x-1) and fib(x-2), and
	# place it in register r14, so we can return it.
	add r14, r14, r3

	# Retrieve the return address from the stack,
	# bump the stack pointer up, and return.

fib_return:
	inc r15, -3		# move the stack pointer back down
	ld1 r13, r15, 0		# restore r13 (the return address)
	ld1 r2, r15, 1		# restore r2
	ld1 r3, r15, 2		# restore r3
	beq r13, r0, r0		# branch to the return address.

_data_:

stack:
