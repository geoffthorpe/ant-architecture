# $Id: sieve.asm,v 1.2 2001/03/22 00:41:28 ellard Exp $
# Dan Ellard - ANT Example Programs
# A simple "sieve of Eratosthenes" program to find and print
# the primes less than 100.  Fun to watch in the debugger.
# Register usage:
# r2	- The current candidate to check for primality.
# r3	- The base of the sieve array.
# r4	- The constant 100, the size of the sieve array.
# r5	- Scratch address register and temporary
# r6	- Multiples of the current prime
# r7	- A scratch register for branch addresses.
# r8	- The constant 0xff, to mark visited numbers.
# r9	- The constant '\n', to print between numbers.

	lc  r2, 1
	lc  r3, $base
	lc  r4, 100		# The largest number to check.
	lc  r8, 0xff		# Used to mark visited numbers.
	lc  r9, '\n'

	st1 r8, r3, 0
	st1 r8, r3, 1

prime_loop:
	inc r2, 1		# increment r2
	lc  r7, $exit
	bgt r7, r2, r4 # If r2 > 100, then we're done.

	add r5, r3, r2		# Compute address of sieve[r2]
	ld1 r5, r5, 0		# Load sieve[r2].
	lc  r7, $do_prime
	beq r7, r5, r0		# If sieve[r2] is zero, it is prime,
				# so branch to "do_prime"
	jmp $prime_loop		# otherwise, try again...

do_prime:			# We found a prime!
	out r2, Hex		# print the prime (in Hex)
	out r9, ASCII		# followed by a newline
	add r6, r2, r2		# r6 gets 2 * the prime.

				# Now cross off all of the multiples
sieve_loop:			# of the prime:
	lc  r7, $prime_loop
	bgt r7, r6, r4		# if the current multiple is larger
				# than 100, go back to the prime_loop.
	bgt r7, r0, r6		# deal with overflow!

	add r5, r3, r6		# compute the address of sieve[r6]
	st1 r8, r5, 0		# and mark it as non-prime.
	add r6, r6, r2		# increment r6 by r2, and
	jmp $sieve_loop		# do it again...

exit:
	hlt

_data_:

	# Some padding so that the array lines up in memory
	# in a prettier manner.  The amount of padding depends
	# on the number of instructions, so if you change the 
	# program don't forget to change the padding!

	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0

base:
