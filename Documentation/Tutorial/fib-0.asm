# $Id: fib-0.asm,v 1.4 2002/03/22 16:23:44 ellard Exp $
# Dan Ellard
# An Ant-8 implementation of the recursive fibonacci function.
# Register usage:
# r2 - the base of the stack
# r3 - the return value from the fib function.
# r5  - value to compute the fibonacci number of.

	lc  r2, $stack

	in  r5, Hex	# Read the number...

	jmp $fib
	out r3, Hex
	lc  r3, '\n'
	out r3, ASCII
	hlt  

	# Register usage:
	# r2 - stack pointer.
	# r3 - return value.
	# r4 - return address.
	# r5 - argument value.
	# r6 - scratch value.
fib:
	st1 r1, r2, 0		# preserve the return address on the stack
	inc r2, 1		# increment the stack pointer.
	st1 r5, r2, 0		# preserve the parameter.
	inc r2, 1		# increment the stack pointer.
	st1 r6, r2, 0		# preserve r6.
	inc r2, 1		# increment the stack pointer.

	# Handle the base case first:
	lc  r3, 1
	lc  r4, $fib_return
	lc  r6, 2
	bgt r4, r6, r5	# if 2 > r5, return 1.

	# Compute fib (x-1), and save the result
	#	(returned in r3) in register r6.
	inc r5, -1
	jmp $fib
	add r6, r3, r0

	# Compute fib (x-2), and leave the result
	#	in register r3.
	inc r5, -1
	jmp $fib

	# Compute the sum of fib(x-1) and fib(x-2), and
	# place it in register r3, so we can return it.
	add r3, r3, r6

	# Retrieve the return address from the stack,
	# bump the stack pointer up, and return.

fib_return:
	inc r2, -1		# decrement the stack pointer
	ld1 r6, r2, 0		# restore r6
	inc r2, -1		# decrement the stack pointer
	ld1 r5, r2, 0		# restore r5
	inc r2, -1		# decrement the stack pointer
	ld1 r4, r2, 0		# restore r4 (the return address)
	beq r4, r0, r0		# branch to the return address.

_data_:

stack:
