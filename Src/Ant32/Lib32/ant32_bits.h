#ifndef	_ANT32_BITS_H_
#define	_ANT32_BITS_H_

/*
 * $Id: ant32_bits.h,v 1.3 2002/01/02 02:29:17 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * ant32_bits.h -- Some ugly macros for dealing with bit-level details
 * of the ANT architecture, and how to express these details in C.
 */

	/*
	 * &&& ASSUMPTION:  the machine we're using to host the ANT
	 * virtual machine has 8-bit bytes, and 32-bit integers (or
	 * integers of more than 32-bits).  If this is not true, then
	 * a lot of this gets quite clumsy.
	 *
	 * &&& ASSUMPTION:  the machine that we're using uses standard
	 * two's-complement binary notation to represent integers
	 * (which is extrememly common today).  The MASK macros could
	 * fail on some old and/or weird machines.
	 */

#define	BITS_PER_BYTE		8
#define	BITS_PER_HWORD		(2 * BITS_PER_BYTE)
#define	BYTE_MASK		((1 << BITS_PER_BYTE) - 1)
#define	HWORD_MASK		((1 << BITS_PER_HWORD) - 1)

	/*
	 * Macros to GET the n'th byte (counting from the RIGHT) from
	 * the given binary word x.
	 */

#define	GET_BYTE(x,n)	(((x) >> (n * BITS_PER_BYTE)) & BYTE_MASK)
#define	GET_HWORD(x,n)	(((x) >> (n * BITS_PER_HWORD)) & HWORD_MASK)

	/* Macros to SET the n'th byte (counting from the RIGHT) of
	 * the given binary word x to q.
	 */

#define	PUT_BYTE(x,q,n)		\
	((((q) & BYTE_MASK) << (n * BITS_PER_BYTE)) | \
			((x) & ~(BYTE_MASK) << (n * BITS_PER_BYTE)))
#define	PUT_HWORD(x,q,n)		\
	((((q) & HWORD_MASK) << (n * BITS_PER_HWORD)) | \
			((x) & ~(HWORD_MASK) << (n * BITS_PER_HWORD)))

	/* A few handy wrappers for GET_HWORD.
	 */

#define	HI_16(x)	GET_HWORD(x, 1)
#define	LO_16(x)	GET_HWORD(x, 0)

#define	LOWER_BYTE(x)	((x) & 0xff)
#define	LOWER_WORD(x)	((x) & 0xffffffff)

/*
 * end of ant32_bits.h
 */

#endif	/* _ANT32_BITS_H_ */
