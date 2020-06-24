# Dan Ellard
# add-func.asm - an example of an Ant-32 function call.
#
# A program to compute the sum of 100 and 200, using a very simple
# function.

	# compute addFunction(200, 100).  Note that because of the way
	# the stack is organized, arguments are pushed in the opposite
	# order that they appear.
	push	100
	push	200
	call	$addFunction

	# At this point, g0 contains the sum.  There's nothing else we
	# need to do except restore the stack pointer by popping the
	# parameters back off the stack.  Since we don't actually
	# care about the values of the parameters any more, we can
	# save time by simply incrementing the stack pointer:
	addi	sp, sp, 8

	halt

	# addFunction is a function that computes the sum of two
	# numbers and returns it.
addFunction:
	entry	0		#  No extra space needed.

	# Get the arguments from the stack and put them into
	# registers.  The first argument (which is 200 in this
	# example) is loaded into g0, and the second (which is 100 in
	# this example) is loaded into g1.
	ld4	g0, fp, 8
	ld4	g1, fp, 12

	# Compute the sum in g0, and return it.
	add	g0, g0, g1
	return	g0

# end of add-func.asm
