# Barney Titmouse -- 11/2/96
# palindrome.asm -- gets a line of text from memory and tests
#                      if it is a palindrome.
# Register usage:
#      r2      - A.
#      r3      - B.
#      r4      - the character *A.
#      r5      - the character *B.
#      r6      - used for addresses, constants
#      r7      - used for addresses

start:
        lc 	r2, $string_data	# r2 = A, the start of string_data
        lc      r3, $string_data        # B starts at string_data

length_loop:                            # Move B to the end of the string:
        ld1     r5, r3, 0               # load the byte at B into r5
        lc      r6, $end_length_loop    # where we'll branch if at end
        beq     r6, r5, r0              # if r5 == 0, branch out of loop.
        inc     r3, 1                   # otherwise, increment B,
        jmp     $length_loop        	#  and repeat
end_length_loop:
        inc     r3, -1                  ## subtract 1 to move B back past
                                        #       the 0.
test_loop:
        lc      r6, $is_palin
        bgt     r6, r2, r3              # if A > B, it's a palindrome.

        ld1     r4, r2, 0               # load the byte *A into r4
        ld1     r5, r3, 0               # load the byte *B into r5
        lc      r6, $cont_palin         # address to jump to if should continue
        beq     r6, r4, r5              # if r4 == r5, could be a palindrome.
        jmp     $not_palin          	# Otherwise, go to not_palin

cont_palin:
        inc     r2, 1                   #   increment A,
        inc     r3, -1                  #   decrement B,
        jmp     $test_loop

is_palin:

	lc	r7, $is_palin_str	# put message in r7
	jmp	$print_message		# branch to print_message

not_palin:
	lc	r7, $not_palin_str	# put message in r7

print_message:
	lc	r6, $string_data
	sys	r6, 4			# print out the palindrome

	lc	r6, '\n'
	sys	r6, 3			# print out a newline

	sys	r7, 4			# print out whether it's a palindrome

	lc	r6, '\n'
	sys	r6, 3			# print out a newline

	sys	r0, 0			# Exit

# Data for the program:
_data_:

string_data:
        .byte   'm', 'a', 'd', 'a', 'm'
        .byte   'i', 'm'
        .byte   'a', 'd', 'a', 'm'
        .byte   0

not_palin_str:
	.byte	'i', 's', ' ', 'n', 'o', 't', ' '
	.byte	'a', ' ', 'p', 'a', 'l', 'i', 'n'
	.byte	'd', 'r', 'o', 'm', 'e', 0

is_palin_str:
	.byte	'i', 's', ' '
	.byte	'a', ' ', 'p', 'a', 'l', 'i', 'n'
	.byte	'd', 'r', 'o', 'm', 'e', 0
