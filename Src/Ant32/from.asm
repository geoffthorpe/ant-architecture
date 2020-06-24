# $Id: rom.asm,v 1.3 2001/11/29 19:11:14 ellard Exp $
#
# Copyright 2001 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
# Dan Ellard -- 11/10/2001
#
# Ant-32 Boot ROM
#
# This is the "boot ROM" for the 4-meg version of Ant-32.  This
# machine has 4 megs of physical RAM, contiguous from physical address
# 0 to physical address 0x3fffff.  Because of the way physical memory
# is addressed in (unmapped) system mode, this means that this RAM
# appears to begin at virtual address 0x80000000 and ends at
# 0x803fffff.
#
# In addition to the RAM, there are 4 pages (16K) of ROM that lives at
# the top of the physical address space.  That's where the contents of
# this file are loaded.


# Initialize the stack pointer and frame pointer to the highest
# location in physical memory.
#
# The unmapped segment starts at 0x80000000, and the default memory
# size is 4 Mbytes.  If the memory size changes, change this constant.
#
# Note that this address is actually past the end of physical memory,
# because the stack pointer is pre-decrement/post-increment.

	.text
	lc	sp, 0x80000000		# Base of memory
	addi	sp, sp, 0x40000		# Memory size
	mov	fp, sp

	# Enable exceptions and interrupts, and jump to the
	# application code.

	leh	$antSysRomEH
	cle

	push	20
	push	$buffer
	call	$antSysReadLine
	pop	ze
	pop	ze

foo:
	push	g0
	call	$antSysPrintSDecimal
	pop	ze

	lc	g10, '\n'
	cout	g10

	push	$buffer
	call	$antSysPrintString
	pop	ze

	halt

	j	0x80000000

	.data
buffer:
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0
	.byte	0, 0, 0, 0, 0, 0, 0, 0



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


antSysRomEH_IRQ:
	.ascii	"IRQ"
	.byte	0
antSysRomEH_Bus:
	.ascii	"Bus Error"
	.byte	0
antSysRomEH_Ill:
	.ascii	"Illegal Instruction"
	.byte	0
antSysRomEH_Priv:
	.ascii	"Priviledged Instruction"
	.byte	0
antSysRomEH_Trap:
	.ascii	"TRAP Exception"
	.byte	0
antSysRomEH_Zero:
	.ascii	"Division by Zero"
	.byte	0
antSysRomEH_Align:
	.ascii	"Address Alignment Error"
	.byte	0
antSysRomEH_Seg:
	.ascii	"Priviledged Segment Error"
	.byte	0
antSysRomEH_Reg:
	.ascii	"Register Access Violation"
	.byte	0
antSysRomEH_TLB_Miss:
	.ascii	"TLB Miss"
	.byte	0
antSysRomEH_TLB_Prot:
	.ascii	"TLB Protection"
	.byte	0
antSysRomEH_TLB_Multi:
	.ascii	"TLB Multiple Match"
	.byte	0
antSysRomEH_TLB_Invalid:
	.ascii	"TLB Invalid Index"
	.byte	0
antSysRomEH_Timer:
	.ascii	"Timer Expired"
	.byte	0
antSysRomEH_Unknown:
	.ascii	"UNKNOWN EXCEPTION"
	.byte	0

	.data
antSysRomHexDigits:
	.ascii	"0123456789abcdef"


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

