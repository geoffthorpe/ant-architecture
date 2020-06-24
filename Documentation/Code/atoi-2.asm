# Barney Titmouse -- 11/2/96
# atoi.asm-- Converts text in memory to an integer
# Registers used:
#	r2	- hold the "sign"
#       r3      - used for scratch space
#       r4      - used to hold the sum
#	r5	- holds the string address
#	r6	- holds 1, the increment
#	r7	- used for addresses
#	r8	- 10, constant
#	r9	- '0', constant
#	r10	- constant, the minus sign '-'

        lc      r4, 0                   # Initialize sum to 0.
        lc      r6, 1                   # Initialize the increment to 1
        lc      r8, 10                  # Initialize r8 to 10
        lc      r5, $string_start       # Start at beginning of string
	lc	r9, '0'			# Initialize r9 to '0'
	lc	r10, '-'		# Initialize r10 to '0'

get_sign:
        lc      r2, 1
        ld1     r3, r5, 0               # grab the "sign"
        lc      r7, $negative           # jump if negative
        beq     r7, r3, r10             # if "-", jump
	jmp	$sum_loop		# otherwise, loop.
negative:
        lc      r2, -1                  # Make r2 negative
skip_sign:
        add     r5, r5, r6              # skipped over the sign.

sum_loop:
        ld1     r3, r5, 0               # load the byte *S into r3,

        lc      r7, $end_sum_loop       # where to branch to
        beq     r7, r3, r0              # if r3 == 0, branch out of loop.

        mul     r4, r4, r8              # r4 *= 10.

        sub     r3, r3, r9              # r3 -= '0'.
        add     r4, r4, r3              # sum += r3.

        add     r5, r5, r6              # increment S to the next char.

        jmp     $sum_loop		#  and repeat the loop.
end_sum_loop:
 
        mul     r4, r4, r2           	# set the sign properly.

	sys	r4, 2			# print out the number

	lc	r10, '\n'		# put newline into r10
	sys	r10, 3			# print out a newline

	sys	r0, 0			# Halt

# Data for the program:
_data_:

string_start:
        .byte   '-', '1', '0', '5', 0

# end atoi.asm
