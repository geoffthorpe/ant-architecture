/*
 * $Id: ant_mach.h,v 1.3 2000/03/28 02:39:41 ellard Exp $
 *
 * Dan Ellard -- 10/20/96 -- cs50
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * ant.h -- General grab-bag header file for ANT programs.
 */
 
#ifndef	_ANT_MACH_H_
#define	_ANT_MACH_H_

/* Listings (and types) for the constants for all the opcodes and
 * syscalls.
 */

typedef	enum	{
	OP_HALT		= 0x0,

	OP_LC		= 0x1,
	OP_INC		= 0x2,
	OP_JMP		= 0x3,

	OP_BEQ		= 0x4,
	OP_BGT		= 0x5,
	OP_LD1		= 0x6,
	OP_ST1		= 0x7,

	OP_ADD		= 0x8,
	OP_SUB		= 0x9,
	OP_MUL		= 0xa,
	OP_SHF		= 0xb,
	OP_AND		= 0xc,
	OP_NOR		= 0xd,

	OP_IN		= 0xe,
	OP_OUT		= 0xf

} ant_op_t;

typedef	enum	{
	IO_HEX		= 0,
	IO_BINARY	= 1,
	IO_ASCII	= 2
} ant_io_t;

typedef	unsigned char	ant_pc_t;

/*
 * The data and instruction address spaces start at zero and have a
 * top address of ANT_INST_ADDR_RANGE-1 and ANT_ADDR_RANGE-1. 
 * Similarly, register numbers range from 0 to ANT_REG_RANGE-1.
 *
 * These constants are currently defined to be the largest possible,
 * given the number of bits available for each type of address. 
 * However, this is not necessarily the case; you could imagine a
 * version of the ANT with less data memory or fewer registers (so
 * before accessing any address, check against these constants to see
 * if it's OK).
 */

#define	ANT_ADDR_RANGE		256
#define	ANT_REG_RANGE		16

/*
 * The following instruction is used to specify an uninitialized word
 * in instruction memory.  By definition, it cannot represent a valid
 * instruction.
 */

#define	ILLEGAL_INSTRUCTION	0xffff

/*
 * The ANT architecture reserves two special registers: One that
 * always holds the constant zero, and the other that holds various
 * useful side-effects from many of the instructions.  In the current
 * version of ANT, these are always registers 0 and 1, respectively,
 * but you should use these definitions in case the designers change
 * their minds later.
 */

#define	ZERO_REG		0
#define	SIDE_REG		1

/*
 * Errors that might be detected during the execution of an ANT
 * program.  These error codes are not part of the ANT architecture
 * itself, but may be useful for the implementation of your ANT VM. 
 * (See ant_fault in ant_utils.c.)
 */

typedef	enum	{
	FAULT_ADDR	= 0x81,	/* an illegal address.		*/
	FAULT_ILL	= 0x82	/* an illegal instruction.	*/
} ant_fault_t;

#define	OP_NIBBLE		3
#define	REG1_NIBBLE		2
#define	REG2_NIBBLE		1
#define	REG3_NIBBLE		0
#define	CONST_BYTE		0
#define	CONST_NIBBLE		0

/*
 * Some useful constants-- the number of bits per ANT word, and
 * from this number of bits, the largest and smallest 8-bit two's
 * complement numbers.  Used to detect if overflow/underflow have
 * occurred in some of the arithmetic operations.
 */

#define ANT_BITS_PER_WORD	8
#define	MAX_ANT_INT		((1 << (ANT_BITS_PER_WORD - 1)) - 1)
#define	MIN_ANT_INT		(-(1 << (ANT_BITS_PER_WORD - 1)))

/*
 * end of ant_mach.h
 */
#endif	/* _ANT_MACH_H_ */
