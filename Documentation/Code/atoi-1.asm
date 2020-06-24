# Barney Titmouse -- 11/02/96
# atoi.asm-- Converts text in memory to an integer
# Registers used:
#       r3      - used for scratch space
#       r4      - used to hold the sum
#	r5	- holds the string address
#	r6	- holds 1, the increment
#	r7	- 10, constant
#	r8	- '0', constant

        lc      r4, 0                   # Initialize sum to 0.
        lc      r5, $string_start       # Start at beginning of string
        lc      r6, 1                   # Initialize the increment to 1
        lc      r7, $end_sum_loop       # where to branch to
        lc      r8, 10                  # Initialize r8 to 10
        lc      r9, '0'                 # Initialize r9 to '0'

sum_loop:
        ld1     r3, r5, 0               # load the byte *str into r3,
        beq     r7, r3, r0              # if r3 == 0, branch out of loop.
        mul     r4, r4, r8              # r4 *= 10.
        sub     r3, r3, r9              # r3 -= '0'.
        add     r4, r4, r3              # sum += r3.
        inc     r5, 1                   # increment str to the next char.
        jmp     $sum_loop               #  and repeat the loop.
end_sum_loop:

	sys	r4, 2			# print out the number

	lc	r10, '\n'		# put newline into r10
	sys	r10, 3			# print out a newline

	sys	r0, 0			# halt


_data_:

string_start:
        .byte   '1', '0', '5', 0

# end atoi.asm
