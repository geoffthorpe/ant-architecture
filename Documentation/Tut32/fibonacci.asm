# Dan Ellard
# fibonacci.asm - An Ant-32 program to recursively compute fibonacci numbers.
#
# To compute fibonacci(5), push the 5 on the stack and then use "call"
# to invoke the fibonacci function.  In this program, since we don't
# use g1 after calling the fibonacci function, we don't need to save
# and restore it.

main:
	lc	g1, 5
	push	g1
	call	$fibonacci	# Call Fibonacci(5)
	addi	sp, sp, 4	# Restore stack pointer
	halt			# and halt.

# The fibonacci function:  computes the X'th Fibonacci number as the
# sum of the (X-1)'th and (X-2)'th Fibonacci numbers.  The base case
# is that if 0'th and 1'st Fibonacci numbers are 1.
#
# Takes a single argument X, accessible at fp + 8.  Assumes that X is
# positive or zero.  If negative, this function will fail!  Try it if
# you want to see what stack overflow looks like...

fibonacci:
	entry	0
	ld4	g1, fp, 8	# g1 gets a copy of the current X

	# If g1 is 0 or 1, then we've reached a base case.
	jezi	g1, $fibonacci_basecase
	subi	g1, g1, 1	# decrement g1 (computing X-1)
	jezi	g1, $fibonacci_basecase
fibonacci_recurse:
	push	g1		# push argument (X-1)
	call	$fibonacci	# recursively call fibonacci
	pop	g1		# pop argument (X-1)
	mov	g2, g0		# save value of fibonacci(X-1) in g2
	subi	g1, g1, 1	# g1 = X-2
	push	g2		# preserve g2
	push	g1		# push argument (X-2)
	call	$fibonacci
	pop	g1		# pop (X-2)
	pop	g2		# restore g2
	add	g0, g0, g2	# compute fibonacci(X-2) + fibonacci(X-1)
	return	g0		# return the sum...
fibonacci_basecase:
	return	1

