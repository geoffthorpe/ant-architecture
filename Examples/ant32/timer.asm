# $Id: timer.asm,v 1.1 2001/02/21 12:39:41 ellard Exp $
#
# Copyright 2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# timer.asm - a very simple example of the timer and the timer
# exception.

	lc	r3, 10		# cycles between timer interrupts.
	lcl	r4, 'a'		# characters printed later.
	lcl	r5, 'b'
	lcl	r6, '\n'

	leh	$handler	# handler for all exceptions.
	cle			# enable exceptions
	cli			# enable interrupts 
	timer	r0, r3		# set the timer to go off in 10 cycles
	j	$print_a

handler:
	cout	r6		# print a newline
	cle			# enable exceptions
	cli			# enable interrupts 
	timer	r0, r3		# reset the timer to go off in 10 cycles
	j	r2		# jump to the address in r2.

print_a:
	# The interrupt handler always finishes by jumping to the
	# address in r2.  So, to break the monotony of always printing
	# 'a's, we load the address $print_b into r2, so that the next
	# time the handler is invoked we'll jump to the print_b
	# routine.

	lc	r2, $print_b

	# An infinite loop that just prints the contents of r4 (which
	# happens to be 'a') forever...  or so it would seem.  It does
	# not go on forever, because when the timer interrupt occurs
	# control jumps back to the handler.
loop_a:
	cout	r4
	bezi	r0, -1

	# print_b and loop_b are just like print_a and loop_a.
print_b:
	lc	r2, $print_a
loop_b:
	cout	r5
	bezi	r0, -1

# end of timer.asm
