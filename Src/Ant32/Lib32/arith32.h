#ifndef	_ARITH32_H_
#define	_ARITH32_H_

/*
 * $Id: arith32.h,v 1.5 2002/01/02 02:29:19 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * Full 32-bit multiplication, addition, and subtraction using 32-bit ops.
 */

int		mul32x32 (int a, int b, int *hi);
int		add32x32 (int a, int b, int *hi);
int		sub32x32 (int a, int b, int *hi);
int		add64x64 (int a0, int a1, int b0, int b1, int *hi);

/*
 * end of arith32.h
 */

#endif	/* _ARITH32_H_ */
