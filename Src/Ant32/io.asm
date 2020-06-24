#
# Sara R. Susskind -- 11/18/01
# printChar-- A function that prints a character
# one argument: character to be printed
# Registers used:
#
# g3  - argument register, holds character to be printed

printChar:
	ld4  g3, fp, 12		# read the argument from the stack
        cout g3			# Print the character.


	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  ze, sp, 0		# push return value onto stack
				# but this function has no return value,
				# so push zero?  or should we just leave
				# the stack alone?
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of printChar


#
# Sara R. Susskind -- 11/18/01
# printString-- A function that prints a character string
# one argument: address of null-terminated string

# Registers used:
#
# g3  - argument register, address of the string
# g6  - next character to be printed.

printString:
	ld4  g3, fp, 12		# read the argument from the stack

ps_loop:
        ld1  g6, g3, 0		# Get the first character from the string
        jezi g6, $ps_done	# If the char is zero, we're finished.
        cout g6			# Otherwise, print the character.
        addi g3, g3, 1		# Increment g3 to point to the next char
        j    $ps_loop

ps_done:
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  ze, sp, 0		# push return value onto stack
				# but this function has no return value,
				# so push zero?  or should we just leave
				# the stack alone?
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of printString


#
# Sara R. Susskind -- 11/18/01
# printHex-- A function that prints a Hex Number
# one argument: integer to be printed

# Registers used:
#
# g1  - used in loop to shift each hex digit
# g2  - bit offset
# g3  - argument
# g4  - used to check if there are digits left to print
# g5  - single hex digit mask
# g6  - largest ascii number

printHex:
	ld4   g3, fp, 12	# read the argument from the stack
        lc    g2, 28          	# bit offset of current nybble
        lc    g5, 0xf          	# single hex digit mask
        lc    g6, '9'		# largest ascii number

ph_loop:   
	addi  g1, g3, 0		#copy input to g1
        shru  g1, g1, g2       	#shift bits to the right
        and   g1, g1, g5       	#select only the last four bits
                                # we now have a number from 0-15
        addi  g1, g1, '0'	#convert to ascii character value
        gts   g4, g1, g6	#A-F need additional offset
        jezi  g4, $ph_output    # char is < A, print this char
        addi  g1, g1, 7		# add to ascii value

ph_output:
	cout g1
        addi g2, g2, -4		#reduce the shift for next four bits
        ges  g4, g2, ze		#if we have bits left, keep going
        jnzi g4, $ph_loop	# loop back to ph_loop

        addi ra, ra, 4		# increment the return address

ph_done:
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  ze, sp, 0		# push return value onto stack
				# but this function has no return value,
				# so push zero?  or should we just leave
				# the stack alone?
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of printHex


#
# Sara R. Susskind -- 11/18/01
# printDecimal-- A function that prints a signed integer
# one argument: integer to be printed

# Registers used:
#
# g1  - holds value to be printed
# g2  - divisor
# g3  - argument
# g4  - used for results of comparison operations
# g6  - flag used to supress leading zeros

printDecimal:
	ld4   g3, fp, 12	# read the argument from the stack
        lc    g2, 1000000000	# divisor, start with highest possible power
	lc    g6, 0		# flag: have we past the leading zeros?
	ges   g4, g3, ze	# is input non-negative?
	jnzi  g4, $pd_loop	# if non-negative, skip printing minus sign
	lc    g1, '-'
	cout  g1		# print a minus sign

pd_loop:   
	div   g1, g3, g2	# put current highest digit in g1
	mod   g3, g3, g2	# keep the remainder in g3 for next time
	ges   g4, g1, ze        # check sign of current digit
        jnzi  g4, $pd_pos		# if non-negative, then don't negate
	muli  g1, g1, -1	# otherwise, negate it
pd_pos:
        jnzi  g6, $pd_out	# if past leading zeros, jump to pd_out
	jezi  g1, $pd_next	# else if zero digit, jump to pd_next
	lcl   g6, 1             # else note that output has started
pd_out:
	addi  g1, g1, '0'
	cout  g1		# print digit
pd_next:
	divi  g2, g2, 10	# reduce divisior one order of magnitude
	jnzi  g2, $pd_loop		# jump to pd_loop

pd_done:
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  ze, sp, 0		# push return value onto stack
				# but this function has no return value,
				# so push zero?  or should we just leave
				# the stack alone?
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of printDecimal


#
# Sara R. Susskind -- 11/18/01
# printUnsigned-- A function that prints a Unsigned Integer
# one argument: integer to be printed

# Registers used:
#
# ra  - return address
# g1  - holds value to be printed
# g2  - divisor
# g3  - argument
# g4  - used for results of comparison operations
# g5  - stores the lowest bit for the first digit of "negative" number
# g6  - flag used to supress leading zeros
# g7  - holds special case divisor for first digit of negative number

printUnsigned:
	ld4   g3, fp, 12	# read the argument from the stack
        lc    g2, 1000000000	# divisor, start with highest possible power
        lc    g7, 500000000	# special divisor
	lc    g6, 0		# flag: have we past the leading zeros?
	lc    g8, 1		# used as mask for negative case
	ges   g4, g3, ze	# is input non-negative?
	jnzi  g4, $pu_loop	# if non-negative, skip to regular output

				# else, handle first digit differently
	lcl   g6, 1		# there are no leading zeros in this case
				#   so set flag accordingly
	and   g5, g3, g8	# keep the lowest bit for later
	shrui g1, g3, 1		# effectively this is unsigned divide by 2
				#   and the result is always positive
	mod   g3, g1, g7        # set the remainder aside
	div   g1, g1, g7	# combines with div by 2 to give div by 10
	addi  g1, g1, '0'	# convert result to ascii
	cout  g1
	muli  g3, g3, 2		# get back (almost) to real remainder
	add   g3, g3, g5	# restore possible lost bit to remainder
	divi  g2, g2, 10	# reduce divisior one order of magnitude

pu_loop:   
	div   g1, g3, g2	# put current highest digit in g1
	mod   g3, g3, g2	# keep the remainder in g3 for next time
	ges   g4, g1, ze        # check sign of current digit
        jnzi  g4, $pu_pos	# if non-negative, then don't negate
	muli  g1, g1, -1	# otherwise, negate it
pu_pos:
        jnzi  g6, $pu_out	# if past leading zeros, jump to pu_out
	jezi  g1, $pu_next	# else if zero digit, jump to int_next
	lcl   g6, 1             # else note that output has started
pu_out:
	addi  g1, g1, '0'
	cout  g1		# print digit
pu_next:
	divi  g2, g2, 10	# reduce divisior one order of magnitude
	jnzi  g2, $pu_loop	# jump to pu_loop

pu_done:
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  ze, sp, 0		# push return value onto stack
				# but this function has no return value,
				# so push zero?  or should we just leave
				# the stack alone?
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of printUnsigned


#
# Sara R. Susskind -- 11/18/01
# readChar-- A function that reads a character
# no arguments
# returns the character
# Registers used:
#
# g3 - stores the character read

readChar:
        cin  g3			# Get the character.

	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  g3, sp, 0		# push return value onto stack
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of readChar


#
# Sara R. Susskind -- 11/18/01
# readLine-- A function that reads a line into memory
# two arguments: buffer address, buffer length
# characters are read until EOL char is encountered
# at most length-1 characters are copied into buffer (always null-terminated)
#   rest of line is not read if buffer fills
# return value is number of characters copied
#

readLine:
	ld4  g1, fp, 16		# get arg1, buffer address, from stack
	ld4  g2, fp, 12		# get arg2, buffer length, from stack
	subi g2, g2, 1		# save space in buffer for null termination
	lc g6, 0		# buffer count

rl_loop:
	cin  g3
	lcl  g5, '\n'
	eq   g4, g5, g3		# test for EOL
	jnzi g4, $rl_done	# if matches EOL, we're done
	st1  g3, g1, 0		# put character into buffer
	addi g1, g1, 1		# increment buffer pointer
	addi g6, g6, 1		# increment character count (for return value)
	subi g2, g2, 1          # decrement number of chars left in buffer
	jnzi g2, $rl_loop	# if buffer space remains, goto rl_loop
rl_done:
	lcl g5, 0
	st1 g5, g1, 0		# add null termination

				# if we were going to try to use up remaining
				# input (for the full buffer case) we'd
				# do it here.

	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  g6, sp, 0		# push return value onto stack
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of readLine


#
# Sara R. Susskind -- 11/18/01
# readHex-- A function that reads a hex number and returns the value
# no arguments
# characters are read until char outside of ranges 0-9,a-f,A-F is encountered
# returns value entered up to unexpected character
# if first character is invalid, returns zero
#

readHex:
	lc   g2, 8		#max input size
	lc   g1, 0		# return value
	lc   g6, '0'
	lc   g7, '9'
	lc   g8, 'A'
	lc   g9, 'F'
	lc   g10, 'a'
	lc   g11, 'f'

rh_loop:
	cin  g3
                                # 0-9 range check
	gts  g4, g6, g3		# test if too small, input < '0'
	jnzi g4, $rh_done	# if too small, we're done
	gts  g4, g3, g7		# else, is it in 0-9 range?
	jnzi g4, $rh_af_check	# if > 0-9, goto A-F check
	subi g3, g3, '0'	# in range, adjust value to 0-15 and
	jezi ze, $rh_computation
				#   go to rh_computation

rh_af_check:
                                # A-F range check
	gts  g4, g8, g3		# test if too small, input < 'A'
	jnzi g4, $rh_done	# if too small, we're done
	gts  g4, g3, g9		# else, is it in A-F range?
	jnzi g4, $rh_check	# if > A-F, goto a-f check
	subi g3, g3, 55		# in range, adjust value to 0-15 and
	jezi ze, $rh_computation
				#   goto rh_computation

rh_check:
                                # a-f range check
	gts  g4, g10, g3	# test if too small, input < 'a'
	jnzi g4, $rh_done	# if too small, we're done
	gts  g4, g3, g11	# else, is it in a-f range?
	jnzi g4, $rh_done	# if > a-f, we're done
	subi g3, g3, 87		# in range, adjust value to 0-15

rh_computation:
	shli g1, g1, 4		# multiply by one hex order of magnitude
	or   g1, g1, g3		# "add" in newest digit
	subi g2, g2, 1		# check number of digits entered so far
	jnzi g2, $rh_loop	# get next digit

rh_done:
	cout g3			#print stopper character
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  g1, sp, 0		# push return value onto stack
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of readHex


#
# Sara R. Susskind -- 11/18/01
# readDecimal-- A function that reads an ASCII signed number and returns value
# no arguments
# characters are read until char outside of range 0-9 is encountered
# returns value entered up to unexpected character
# if first character is invalid, returns zero
# doesn't check for overflow, but limits to 10 digit numbers
#

readDecimal:
	lc   g2, 10		# max input size
	lc   g1, 0		# return value
	lc   g5, 0		# flag indicates negative number
	lc   g6, '0'
	lc   g7, '9'
	lc   g8, '-'

rd_loop:
	cin  g3
	jnzi g1, $rd_range_check
				# don't check for minus sign if return
				#   value is non-zero.  This is not fully
				#   correct, user could enter zeros followed
				#   by dashes, and get a number, e.g. 00-0--5
				#   would yield -5
	eq   g4, g3, g8		# check for minus sign
	jezi g4, $rd_range_check
				# not a minus sign, goto rd_range_check
	lcl  g5, 1		# set minus flag
	jnzi g4, $rd_loop	# after minus sign, get another char right away

rd_range_check:
	gts  g4, g6, g3		# test if too small, input < '0'
	jnzi g4, $rd_done	# if too small, we're done
	gts  g4, g3, g7		# else, is it in 0-9 range?
	jnzi g4, $rd_done	# if > 0-9, we're done
	subi g3, g3, '0'	# in range, adjust value to 0-15 and

	muli g1, g1, 10		# multiply by one order of magnitude
	add  g1, g1, g3		# add in newest digit
	subi g2, g2, 1		# check number of digits entered so far
	jnzi g2, $rd_loop	# get next digit

rd_done:
	jezi g5, $rd_done_pos	# if not minus, jump to return
	muli g1, g1, -1		# else negate number
rd_done_pos:
	
	addi sp, fp, 0		# restore the stack pointer
				#   (not really necessary because this function
				#    doesn't change the stack)
	st4  g1, sp, 0		# push return value onto stack
	subi sp, sp, 4
        addi ra, ra, 4		# increment the return address
	jez  ze, ze, ra		# Jump back to return address

# end of readDecimal
