# $Id: rom.asm,v 1.9 2002/01/02 02:27:32 ellard Exp $
#
# Copyright 2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Dan Ellard -- 11/10/2001
#
# Ant-32 Boot ROM
#
# This is the simple "boot ROM" for the generic version of Ant-32. 
# This machine typically has 4 megs of physical RAM, contiguous from
# physical address 0 to physical address 0x3fffff.  Because of the way
# physical memory is addressed in (unmapped) system mode, this means
# that this RAM appears to begin at virtual address 0x80000000 and
# ends at 0x803fffff.  However, other RAM sizes are possible, so the
# first thing this program does is probe memory to find its size.
#
# In addition to the RAM, there are 4 pages (16K) of ROM that lives at
# the top of the physical address space.  That's where the contents of
# this file are loaded.  This booter is not intelligent enough to deal
# with any other ROM sizes.
#
# This boot ROM assumes that the memory image for the main program has
# already been loaded into memory, starting at memory location
# 0x80000000.
#
# In addition to the boot sequence, there are also several utility
# functions that can be executed out of the ROM by any program.
# 
# Note that there is nothing sacred here-- all of the initializations
# done here can be overridden by the "real" boot sequence.  The
# purpose of this ROM is simply to supply reasonable defaults so that
# it is, for many purposes, unnecessary to override anything.  The
# only really important thing that the main code needs to take into
# account is that exceptions are enabled by the ROM.

	.text

	# Step 1:  find how much physical RAM is installed.
	#
	# This is done by starting at address 0 in physical memory
	# (virtual address 0x80000000) and then scanning up through
	# physical memory page by page, trying to read the first word
	# of each page, until we either reach the end of the physical
	# address space, or we get an exception because we tried to
	# access a page that doesn't exist.  This assumes that memory
	# is contiguous starting at physical address 0, and always is
	# a multiple of the page size, but these assumptions are part
	# of the machine spec, so they're reasonable assumptions.
	#
	# We also assume that the only possible exception that can
	# occur at this point is a memory access error, so we don't
	# need to check the exception number (and we can install a
	# special-purpose exception handler).

	leh	$antSysRom_end_probe
	cle				# enable exceptions (because we
					# EXPECT a memory access exception).
	lc	g2, 0xC0000000		# max address of physical RAM + 1.
	lc	g0, 0x80000000		# base of physical RAM

antSysRom_probe_loop:
	ges	g1, g0, g2
	jnzi	g1, $antSysRom_end_probe
	ld4	ze, g0, 0
	addi	g0, g0, 0x1000		# increment g0 by page size.
	j	$antSysRom_probe_loop
antSysRom_end_probe:

	# If we get here, it's either because we ran out of memory
	# locations to probe, or we probed somewhere that doesn't
	# exist.  Either way, g0 is what we want-- the address past
	# the end of physical memory.  Time to move on.

	# Step 2:  initialize sp and fp.
	#
	# At this point, g0 contains the address of the first word of
	# the first page past the end of physical memory.  That's what
	# we're going to use as the initial values of the stack
	# pointer and frame pointer.
	#
	# Note that the initial address is actually past the end of
	# physical memory, because the stack pointer is
	# pre-decrement/post-increment.

	mov	sp, g0
	mov	fp, g0

	# Step 3:  set the exception handler, enable exceptions, and
	# reinitialize the cycle counters (because if there's a lot of
	# RAM, they might run up quite a bit during the memory probe) and
	# any other registers used by the previous routines.
	# 
	# There's no way to perfectly clear out the cycle counters,
	# because as soon as we zero anything, the cycle count will
	# start to grow again.  But we try to make the best of things
	# by zero-ing the instruction counters last.  This is a hack.

	leh	$antSysRomEH
	cle

	lc	g1, 0
	lc	g2, 0

	lc	c2, 0
	lc	c3, 0
	lc	c4, 0
	lc	c5, 0
	lc	c6, 0
	lc	c7, 0
	lc	c0, 0
	lc	c1, 0

	# Call the application code, and handle the return (if any).
	#
	# Some programs can treat the entry to the main as a procedure
	# call...  and therefore could return control here when they
	# are finished.  In that case, be sure to stop things here!
	#
	# It would be nice to use antSysPrintStr to print out a little
	# farewell message, but since we don't know how we go here
	# (i.e maybe we got here because the main procedure smashed
	# the stack and is bailing out...) we can't assume that a
	# procedure call is going to actually work.  So, we just
	# silently halt.
	#
	# The unmapped segment starts at 0x80000000, and it assumed
	# that the start of the main program begins there as well.

	push	g0
	lc	g0, 0			# Reset g0
	call	0x80000000
	halt

	# That's all!

# The default exception handler doesn't do anything very interesting. 
# It doesn't really "handle" the exception, it just prints out an
# error message and halts.  It doesn't make any effort to restore the
# state of the system and continue-- so therefore it doesn't need to
# make any effort to save the state of the system.  It may trash the
# u-registers and k-registers.

	.text
antSysRomEH:

	lc	k0, 0xf
	and	k0, k0, e3	# k0 gets bits 2-0 of e0

	# &&& Right now, we don't do anything with k0.  It would be
	# nice to do something meaningful eventually.

	shrui	k1, e3, 4	# k1 gets exception number (from e0);
	muli	k1, k1, 4
	addi	k1, k1, $antSysRomEHVecText
	ld4	k1, k1, 0
	lc	k3, $antSysRomEHendLoop

	# Print the string pointed to by k1.  It is tempting to use
	# the printString function, but that might not work-- it might
	# have been a problem with the stack that caused the exception
	# in the first place.  Therefore, we'll just do the work of
	# printing the string here.

antSysRomEHloop:
	ld1	k2, k1, 0
	jez	ze, k2, k3
	cout	k2
	addi	k1, k1, 1
	j	$antSysRomEHloop
antSysRomEHendLoop:
	lc	k2, '\n'
	cout	k2
	halt

	.data
	.align	4
antSysRomEHVecText:
	.word	$antSysRomEH_Unknown		# 0
	.word	$antSysRomEH_IRQ		# 1
	.word	$antSysRomEH_Unknown		# 2
	.word	$antSysRomEH_Bus		# 3
	.word	$antSysRomEH_Ill		# 4
	.word	$antSysRomEH_Priv		# 5
	.word	$antSysRomEH_Trap		# 6
	.word	$antSysRomEH_Zero		# 7
	.word	$antSysRomEH_Align		# 8
	.word	$antSysRomEH_Seg		# 9
	.word	$antSysRomEH_Reg		# 10
	.word	$antSysRomEH_TLB_Miss		# 11
	.word	$antSysRomEH_TLB_Prot		# 12
	.word	$antSysRomEH_TLB_Multi		# 13
	.word	$antSysRomEH_TLB_Invalid	# 14
	.word	$antSysRomEH_Unknown		# 15
	.word	$antSysRomEH_Unknown		# 16
	.word	$antSysRomEH_Unknown		# 17
	.word	$antSysRomEH_Unknown		# 18
	.word	$antSysRomEH_Unknown		# 19
	.word	$antSysRomEH_TLB_Invalid	# 20

antSysRomEH_IRQ:		.asciiz	"IRQ"
antSysRomEH_Bus:		.asciiz	"Bus Error"
antSysRomEH_Ill:		.asciiz	"Illegal Instruction"
antSysRomEH_Priv:		.asciiz	"Priviledged Instruction"
antSysRomEH_Trap:		.asciiz	"TRAP Exception"
antSysRomEH_Zero:		.asciiz	"Division by Zero"
antSysRomEH_Align:		.asciiz	"Address Alignment Error"
antSysRomEH_Seg:		.asciiz	"Priviledged Segment Error"
antSysRomEH_Reg:		.asciiz	"Register Access Violation"
antSysRomEH_TLB_Miss:		.asciiz	"TLB Miss"
antSysRomEH_TLB_Prot:		.asciiz	"TLB Protection"
antSysRomEH_TLB_Multi:		.asciiz	"TLB Multiple Match"
antSysRomEH_TLB_Invalid:	.asciiz	"TLB Invalid Index"
antSysRomEH_Timer:		.asciiz	"Timer Expired"
antSysRomEH_Unknown:		.asciiz	"UNKNOWN EXCEPTION"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# An EXTREMELY simple memory allocator.  Similar to sbrk, but doesn't
# require the increment to be a multiple of the page size.
#
# antSysSbrkInit is used initially to set the break between program
# data and unused memory-- it SHOULD always be the lowest address not
# used by the data or text areas of the program.  Unfortunately, the
# system doesn't currently have any way to determine this address when
# an arbitrary program is loaded, so it's up to the program to call
# antSysSbrkInit to set the initial value.  Therefore, by default the
# break is set to 0, which is sure to cause a runtime error if the
# programmer forgets to initialize it.
#
# antSysSbrk is used to set the break.  It can be used to move the
# break in either direction (effectively allocating or deallocating
# memory), or just to find the current value of the break.  The
# argument is how far to move the break-- positive allocates memory,
# and negative deallocates memory.  An argument of zero causes simply
# returns the current value of the break.  The increment (or
# decrement) is always rounded up to the nearest multiple of 4, so
# that the returned pointer is properly aligned for any kind of
# purpose.  The return address is the value the break had before it
# was incremented.
#
# Note that using a negative increment, or an increment larger than
# available memory (or one that clobbers that stack) is not detected. 
# As mentioned before, this is an EXTREMELY simple memory allocator...
#
# NOTE-- because of the alignment restriction that the break must
# always obey, it is possible to "leak" memory by trying to deallocate
# fractions of a word.  For example, trying to move back the break by
# a single byte doesn't actually change the break at all-- while
# moving the break forward by less than a word always results in the
# break moving.
#
# IMPORTANT IMPLEMENTATION NOTE - in Ant-32 version 3.1.0, the ROM is
# actually writable, due to a bug in the simulator.  I'm taking
# advantage of this bug to store this variable in the "ROM".  Yes, I
# know this is lame, but it really simplifies everything in the short
# run.  -DJE

	.data
antSysSbrkWord:
	.word	0

	.text
antSysSbrkInit:
	entry	0
	ld4	g1, fp, 8
	lc	g2, $antSysSbrkWord
	st4	g1, g2, 0
	return

	.text
antSysSbrk:
	entry	0
	ld4	g1, fp, 8
	lc	g2, $antSysSbrkWord
	ld4	g3, g2, 0

	mov	g0, g3
	modi	g4, g1, 4
	jezi	g4, $antSysSbrk_aligned

	shrui	g1, g1, 2
	shli	g1, g1, 2
	addi	g1, g1, 4

antSysSbrk_aligned:
	add	g3, g3, g1
	st4	g3, g2, 0
	return	g0

# I/O Routines originally written by Sara R. Susskind:
#
# printString-- A function that prints a zero-terminated
# character string.  Takes one argument, which is the address
# of the first character in the string.
#
# Registers used:
#
# g1  - argument register, address of the string
# g2  - next character to be printed.

	.text
antSysPrintString:
	entry	0
	ld4	g1, fp, 8	# read the argument from the stack

antSysPrintString_loop:
        ld1	g2, g1, 0	# Get the first character from the string
				# If the char is zero, we're finished.
        jezi	g2, $antSysPrintString_done
        cout	g2		# Otherwise, print the character.
        addi	g1, g1, 1	# Increment g3 to point to the next char
        j	$antSysPrintString_loop

antSysPrintString_done:
	return

# end of printString

# printSDecimal-- A function that prints a signed integer as decimal.
# one argument: integer to be printed
#
# Registers used:
#
# g1  - holds value to be printed
# g2  - divisor
# g3  - argument
# g4  - used for results of comparison operations
# g6  - flag used to supress leading zeros

	.text
antSysPrintSDecimal:
	entry	0

	ld4	g3, fp, 8	# read the argument from the stack
				# First check the special case that
				# the argument is simply 0.
	jnzi	g3, $antSysPrintSD_nonzero
	lc	g1, '0'
	cout	g1
	return

antSysPrintSD_nonzero:
        lc	g2, 1000000000	# divisor, start with highest possible power
	lc	g6, 0		# flag: have we past the leading zeros?
	ges	g4, g3, ze	# is input non-negative?
				# if non-negative, skip printing minus sign
	jnzi	g4, $antSysPrintSD_loop
	lc	g1, '-'
	cout	g1		# print a minus sign

antSysPrintSD_loop:   
	div	g1, g3, g2	# put current highest digit in g1
	mod	g3, g3, g2	# keep the remainder in g3 for next time
	ges	g4, g1, ze        # check sign of current digit
				# if non-negative, then don't negate
        jnzi	g4, $antSysPrintSD_pos
	muli	g1, g1, -1	# otherwise, negate it
antSysPrintSD_pos:
				# if past leading zeros,
				# then jump to antSysPrintSD_out
        jnzi	g6, $antSysPrintSD_out
	jezi	g1, $antSysPrintSD_next
				# else if zero digit, jump to antSysPrintSD_next
	lcl	g6, 1		# else note that output has started
antSysPrintSD_out:
	addi	g1, g1, '0'
	cout	g1		# print digit
antSysPrintSD_next:
	divi	g2, g2, 10	# reduce divisior one order of magnitude
				# jump to antSysPrintSD_loop
	jnzi	g2, $antSysPrintSD_loop

antSysPrintSD_done:
	return

# end of printDecimal

#
# Sara R. Susskind -- 12/5/01 
# antSysPrintUDecimal-- A function that prints a Unsigned Decimal
# one argument: decimal to be printed

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

antSysPrintUDecimal:
        entry   0

        ld4     g3, fp, 8       # read the argument from the stack
                                # First check the special case that
                                # the argument is simply 0.
        jnzi    g3, $antSysPrintUD_nonzero
        lc      g1, '0'
        cout    g1
        return

antSysPrintUD_nonzero:
        lc    g2, 1000000000    # divisor, start with highest possible power
        lc    g7, 500000000     # special divisor
        lc    g6, 0             # flag: have we past the leading zeros?
        lc    g8, 1             # used as mask for negative case
        ges   g4, g3, ze        # is input non-negative?
        jnzi  g4, $antSysPrintUD_loop            
				# if non-negative, skip to regular output

                                # else, handle first digit differently
        lcl   g6, 1             # there are no leading zeros in this case
                                #   so set flag accordingly
        and   g5, g3, g8        # keep the lowest bit for later
        shrui g1, g3, 1         # effectively this is unsigned divide by 2
                                #   and the result is always positive
        mod   g3, g1, g7        # set the remainder aside
        div   g1, g1, g7        # combines with div by 2 to give div by 10
        addi  g1, g1, '0'       # convert result to ASCII
        cout  g1
        muli  g3, g3, 2         # get back (almost) to real remainder
        add   g3, g3, g5        # restore possible lost bit to remainder
        divi  g2, g2, 10        # reduce divisior one order of magnitude

antSysPrintUD_loop:
        div   g1, g3, g2        # put current highest digit in g1
        mod   g3, g3, g2        # keep the remainder in g3 for next time
        ges   g4, g1, ze        # check sign of current digit
        jnzi  g4, $antSysPrintUD_pos             
				# if non-negative, then don't negate
        muli  g1, g1, -1        # otherwise, negate it

antSysPrintUD_pos:
        jnzi  g6, $antSysPrintUD_out             
				# if past leading 0's, jump to antSysPrintUD_out
        jezi  g1, $antSysPrintUD_next             
				# else if 0 digit, jump to antSysPrintUD_next
        lcl   g6, 1             # else note that output has started

antSysPrintUD_out:
        addi  g1, g1, '0'
        cout  g1                # print digit

antSysPrintUD_next:
        divi  g2, g2, 10        # reduce divisior one order of magnitude
        jnzi  g2, $antSysPrintUD_loop           
				# jump to antSysPrintUD_loop

antSysPrintUD_done:
        return                  # Jump back to return address

# end of antSysPrintUDecimal


# printHex-- A function that prints a Hex Number
# one argument: integer to be printed
#
# Registers used:
#
# g1  - used in loop to shift each hex digit
# g2  - bit offset
# g3  - argument
# g4  - used to check if there are digits left to print
# g5  - address of HexDigitsStr.
# g6  - address of hex digit char to print (from HexDigitsStr).
# g7  - hex digit char to print.

	.text
antSysPrintHex:
	entry	0
	ld4	g3, fp, 8	# read the argument.
        lc	g2, 28          # bit offset of current nybble
	lc	g5, $antSysPrintHexDigitsStr

antSysPrintHex_loop:   
        shru	g1, g3, g2      # shift bits to the right
        andi	g1, g1, 0xf     # select only the last four bits
	add	g6, g5, g1
	ld1	g7, g6, 0
	cout	g7
        addi	g2, g2, -4	# reduce the shift for next four bits
        ges	g4, g2, ze	# if we have bits left, keep going.
        jnzi	g4, $antSysPrintHex_loop
antSysPrintHex_done:
	return

	.data
antSysPrintHexDigitsStr:
	.ascii	"0123456789ABCDEF"

# end of printHex

# readLine-- A function that reads a line into memory
# two arguments: buffer address, buffer length
# characters are read until EOL char is encountered
# at most length-1 characters are copied into buffer (always null-terminated)
#   rest of line is not read if buffer fills
# return value is number of characters copied
#

	.text
antSysReadLine:
	entry	0
	ld4	g1, fp, 8	# get arg1, buffer address, from stack
	ld4	g2, fp, 12	# get arg2, buffer length, from stack
	subi	g2, g2, 1	# save space in buffer for null termination
	lcl	g5, '\n'
	lc	g6, 0		# buffer count

antSysReadLine_loop:
	cin	g3
	lts	g4, g3, ze	# if cin failed, we're done.
	jnzi	g4, $antSysReadLine_done

	st1	g3, g1, 0	# put character into buffer
	addi	g1, g1, 1	# increment buffer pointer
	addi	g6, g6, 1	# increment character count (for return value)
	eq	g4, g3, g5	# test for EOL
				# if matches EOL, we're done
	jnzi	g4, $antSysReadLine_done

	subi	g2, g2, 1       # decrement number of chars left in buffer
				# if buffer space remains, iterate
	jnzi	g2, $antSysReadLine_loop
antSysReadLine_done:
	st1	ze, g1, 0	# add null termination

	# if we were going to try to use up remaining input (for the
	# full buffer case) we'd do it here.

	return	g6

# end of readLine
#
# Sara R. Susskind -- 12/05/01
# readDecimal-- A function that reads an ASCII signed number and returns value
# no arguments
# characters are read until char outside of range 0-9 is encountered
# returns value entered up to unexpected character
# if first character is invalid, returns zero
# doesn't check for overflow, but limits to 10 digit numbers
#

antSysReadDecimal:
	entry 0
        lc   g2, 10             # max input size
        lc   g1, 0              # return value
        lc   g5, 0              # flag indicates negative number
        lc   g6, '0'
        lc   g7, '9'
        lc   g8, '-'

antSysReadDec_loop:
        cin  g3
        jnzi g1, $antSysReadDec_range_check
				# don't check for minus sign if return
                                # value is non-zero.  This is not fully
                                # correct, user could enter zeros followed
                                # by dashes, and get a number, e.g. 00-0--5
                                # would yield -5
        eq   g4, g3, g8         # check for minus sign

        jezi g4, $antSysReadDec_range_check              
				# not a '-' sign, goto antSysReadDec_range_check

        lcl  g5, 1              # set '-' flag
        jnzi g4, $antSysReadDec_loop              
				# after minus sign, get another char right away

antSysReadDec_range_check:
        gts  g4, g6, g3         # test if too small, input < '0'
        jnzi g4, $antSysReadDec_done              
				# if too small, we're done
        gts  g4, g3, g7         # else, is it in 0-9 range?
        jnzi g4, $antSysReadDec_done              
				# if > 0-9, we're done
        subi g3, g3, '0'        # in range, adjust value to 0-9 and

        muli g1, g1, 10         # multiply by one order of magnitude
        add  g1, g1, g3         # add in newest digit
        subi g2, g2, 1          # check number of digits entered so far
        jnzi g2, $antSysReadDec_loop            
				# get next digit

antSysReadDec_done:
        jezi g5, $antSysReadDec_return              
				# if not minus, jump to return
        muli g1, g1, -1         # else negate number

antSysReadDec_return:
        return g1               # Jump back to return address

# end of antSysReadDecimal

# Sara R. Susskind -- 11/30/01
# antSysReadHex-- A function that reads a hex number and returns the value
# no arguments
# characters are read until char outside of ranges 0-9,a-f,A-F is encountered
# returns value entered up to unexpected character
# if first character is invalid, returns zero
#

antSysReadHex:
        entry   0
        ld4     g3, fp, 8       # get arg1, hex number, from stack

        lc   g2, 8              #max input size
        lc   g1, 0              # return value
        lc   g6, '0'
        lc   g7, '9'
        lc   g8, 'A'
        lc   g9, 'F'
        lc   g10, 'a'
        lc   g11, 'f'

antSysReadHex_loop:
        cin  g3
                                # 0-9 range check
        gts  g4, g6, g3         # test if too small, input < '0'
        jnzi g4, $antSysReadHex_done       
				# if too small, we're done
        gts  g4, g3, g7         # else, is it in 0-9 range?
        jnzi g4, $antSysReadHex_AF_check   
				# if > 0-9, goto A-F check
        subi g3, g3, '0'        # in range, adjust value to 0-15 and
        jezi ze, $antSysReadHex_computation
                                #   go to antSysReadHex_computation

antSysReadHex_AF_check:
                                # A-F range check
        gts  g4, g8, g3         # test if too small, input < 'A'
        jnzi g4, $antSysReadHex_done       
				# if too small, we're done
        gts  g4, g3, g9         # else, is it in A-F range?
        jnzi g4, $antSysReadHex_check      
				# if > A-F, goto a-f check
        subi g3, g3, 55         # in range, adjust value to 0-15 and
        jezi ze, $antSysReadHex_computation
                                #   goto antSysReadHex_computation

antSysReadHex_check:
                                # a-f range check
        gts  g4, g10, g3        # test if too small, input < 'a'
        jnzi g4, $antSysReadHex_done       
				# if too small, we're done
        gts  g4, g3, g11        # else, is it in a-f range?
        jnzi g4, $antSysReadHex_done       
				# IF > a-f, we're done
        subi g3, g3, 87         # in range, adjust value to 0-15

antSysReadHex_computation:
        shli g1, g1, 4          # multiply by one hex order of magnitude
        or   g1, g1, g3         # "add" in newest digit
        subi g2, g2, 1          # check number of digits entered so far
        jnzi g2, $antSysReadHex_loop       
				# get next digit

antSysReadHex_done:
	return g1

# end of antSysReadHex
