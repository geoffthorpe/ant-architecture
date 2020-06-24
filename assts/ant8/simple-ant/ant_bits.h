#ifndef	_ANT_BITS_H_
#define	_ANT_BITS_H_

/*
 * $Id: ant_bits.h,v 1.3 2000/03/28 02:39:41 ellard Exp $
 *
 * Copyright 1996-2000 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 03/27/2000 -- cs50
 *
 * ant_bits.h -- Some ugly macros for dealing with bit-level details
 * of the ANT architecture, and how to express these details in C.
 */

 /*

	---------------------------------------------------
	| Operator | Register 1 | Register 2 | Register 3 |
	| (4 bits) |  (4 bits)  |  (4 bits)  |  (4 bits)  |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 |        Constant         |
	| (4 bits) |  (4 bits)  |        (8 bits)         |
	---------------------------------------------------
    or
	---------------------------------------------------
	| Operator | Register 1 | Register 2 |  Constant  |
	| (4 bits) |  (4 bits)  |  (4 bits)  |  (4 bits)  |
	---------------------------------------------------

Each ANT instruction is a 16-bit quantity, stored as two consecutive
bytes in memory.  The first byte of the instruction contains the
opcode as its first four bits, and so on.

*/

/*
 * Macros to GET the n'th nibble or byte (counting from the RIGHT, or
 * least significant bits) from the given binary word x.
 *
 * ASSUMPTION:  the machine we're using to host the ANT virtual
 * machine has 8-bit bytes (and therefore 4-bit nibbles).  If this is
 * NOT true, then a lot of these macros still work (as long as
 * BITS_PER_BYTE is larger than 8) but emulating the ANT architecture
 * (which DOES have 8-bit bytes) might require a little more thought.
 */

#define	GET_NIBBLE(x,n)		(((x) >> (n * 4)) & 0xf)
#define	GET_BYTE(x,n)		(((x) >> (n * 8)) & 0xff)

/*
 * A few handy wrappers for GET_BYTE and GET_NIBBLE.  These are
 * probably the only macros on this file that you will actually use;
 * the previous macros are just used to define these:
 */

#define	UPPER_BYTE(x)		GET_BYTE((x),1)
#define	LOWER_BYTE(x)		GET_BYTE((x),0)
#define	UPPER_NIBBLE(x)		GET_NIBBLE((x),1)
#define	LOWER_NIBBLE(x)		GET_NIBBLE((x),0)

/*
 * end of ant_bits.h
 */

#endif	/* _ANT_BITS_H_ */
