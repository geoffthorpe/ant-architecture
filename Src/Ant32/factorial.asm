# factorial.asm
#
# A program to recursively compute the factorial of 4.

main:
	# Set up the stack and frame pointers.  (This is usually done
	# by the executive, but this is included here in order to make
	# this example stand-alone.)

	lc	sp, 0x80002000
	lc	fp, 0x80002000

	# To compute factorial(4), push the 4 on the stack and then
	# use "call" to invoke the factorial function.  In this
	# program, since we're not using any registers other than g1
	# (outside of the factorial function), we don't need to
	# preserve anything.  We don't even care about the original
	# value of g1 when the function returns.

	lc	g1, 4
	push	g1
	call	$factorial
	pop	g1
main_des:
	halt

# The factorial function:
# Computes factorial (X) as factorial (X-1) * X, with the base case
# that the factorial of 0 is 1.  Takes a single argument X, accessible
# at fp + 8.
#
# Assumes that X is positive or zero.  If negative, pathological
# misery will result.  Try it if you want to see what stack overflow
# looks like...

factorial:
	entry	0
	ld4	g1, fp, 8	# g1 gets a copy of the current X
	jezi	g1, $factorial_basecase
factorial_recurse:
	subi	g2, g1, 1	# decrement X
	push	g1		# preserve g1
	push	g2		# push the arg (X-1) and call factorial...
	call	$factorial
	pop	g2		# pop the arg (restoring g2).
	pop	g1		# restore g1.
	mul	g0, g0, g1	# compute X * factorial (X-1),
	return	g0		# and return it.
factorial_basecase:
	return	1

