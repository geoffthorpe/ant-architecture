/*
 * $Id: arith32.c,v 1.11 2002/01/02 02:29:19 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 08/04/99
 *
 * 64-bit multiplication, addition, and subtraction using 32-bit ops.
 *
 * Assumes that the underlying hardware does 32-bit arithmetic.
 */

#include	<stdio.h>
#include	<stdlib.h>

#include	"arith32.h"

#define	GET_HI_16(x)	(((x) >> 16) & 0xffff)
#define	GET_LO_16(x)	((x) & 0xffff)

#define	MAX_INT32	0x7fffffff
#define	MIN_INT32	(-MAX_INT32 - 1)

/*
 * mul32x32 -- perform multiplication of two 32-bit two's complement
 * integers.  This can result in a 64-bit result.  The lower 32 bits
 * are returned from this function, while the upper 32 bits are stored
 * in *hi (if hi is non-NULL).
 *
 * This function assumes that the actual representation for integers
 * is also 32-bit two's complement.  This algorithm can be generalized
 * to work with smaller integers, if necessary, but any representation
 * other than two's complement is going to cause major headaches.
 *
 * The algorithm is as follows:  each input integer (a, b) is split
 * into its high and low 16-bits "digits" (a1, a0, b1, b0), and then
 * the multiplication of these digits is done:
 *
 * a * b = (2^32 * a1 * b1) + 2^16 * (a1 * b0 + a0 * b1) + a0 * b0.
 *
 * A little care is needed to make sure that the carry is done
 * properly.
 *
 * Unfortunately, this algorithm does not work as simply when either
 * of the integers is negative.  To handle this, we first check
 * whether exactly one of the numbers is negative, and take the
 * absolute value of each number, and then do the multiplication.  If
 * exactly one of the arguments is negative, then the resulting 64-bit
 * product is negated (using the explicit two's complement method).
 *
 */

int mul32x32 (int a, int b, int *hi)
{
	int a_terms [2];
	int b_terms [2];
	int res_terms [4] = { 0, 0, 0, 0 };
	int tmp;
	int tmp_lo, tmp_hi;
	int sign = 1;
	int residual = 0;

	/*
	 * deal with the simple cases...
	 */

	if (a == 0 || b == 0) {
		if (hi != NULL) {
			*hi = 0;
		}
		return (0);
	}

	/*
	 * deal with difficult cases next...
	 */

	if (a == MIN_INT32 || b == MIN_INT32) {

		/* If both a and b are MIN_INT32, we just write out
		 * the answer.  Otherwise, we have more work to do--
		 * since we can't negate MIN_INT32, we figure out
		 * which one of them is MIN_INT32 and then add one to
		 * it, and make a note that eventually we'll need to
		 * add an extra term to make the sum right.
		 */

		if (a == MIN_INT32 && b == MIN_INT32) {
			if (hi != NULL) {
				*hi = 0x40000000;
			}
			return (0);
		}
		else if (a == MIN_INT32) {
			residual = -b;
			a++;
		}
		else {
			residual = -a;
			b++;
		}
	}

	if (a < 0) {
		a = -a;
		sign *= -1;
	}

	if (b < 0) {
		b = -b;
		sign *= -1;
	}

	a_terms [0] = GET_LO_16 (a);
	a_terms [1] = GET_HI_16 (a);

	b_terms [0] = GET_LO_16 (b);
	b_terms [1] = GET_HI_16 (b);

	tmp = a_terms [0] * b_terms [0];
	res_terms [0] += GET_LO_16 (tmp);
	res_terms [1] += GET_HI_16 (tmp);

	tmp = a_terms [0] * b_terms [1];
	res_terms [1] += GET_LO_16 (tmp);
	res_terms [2] += GET_HI_16 (tmp);

	tmp = a_terms [1] * b_terms [0];
	res_terms [1] += GET_LO_16 (tmp);
	res_terms [2] += GET_HI_16 (tmp);

	tmp = a_terms [1] * b_terms [1];
	res_terms [2] += GET_LO_16 (tmp);
	res_terms [3] += GET_HI_16 (tmp);

	res_terms [2] += GET_HI_16 (res_terms [1]);
	res_terms [1] = GET_LO_16 (res_terms [1]);

	res_terms [3] += GET_HI_16 (res_terms [2]);
	res_terms [2] = GET_LO_16 (res_terms [2]);

	/*
	 * Negate the result, if appropriate.
	 */

	if (sign < 0) {
		res_terms [0] = GET_LO_16 (~res_terms [0]);
		res_terms [1] = GET_LO_16 (~res_terms [1]);
		res_terms [2] = GET_LO_16 (~res_terms [2]);
		res_terms [3] = GET_LO_16 (~res_terms [3]);

		res_terms [0] += 1;
		res_terms [1] += GET_HI_16 (res_terms [0]);
		res_terms [0] = GET_LO_16 (res_terms [0]);

		res_terms [2] += GET_HI_16 (res_terms [1]);
		res_terms [1] = GET_LO_16 (res_terms [1]);

		res_terms [3] += GET_HI_16 (res_terms [2]);
		res_terms [2] = GET_LO_16 (res_terms [2]);
	}

	tmp_lo = res_terms [0] | (res_terms [1] << 16);
	tmp_hi = res_terms [2] | (res_terms [3] << 16);

	if (residual != 0) {
		tmp_lo = add64x64 (tmp_lo, tmp_hi, residual, 0, &tmp_hi);
	}

	if (hi != NULL) {
		*hi = tmp_hi;
	}

	return (tmp_lo);
}

#define	POSITIVE	(1)
#define	NEGATIVE	(-1)

/*
 * add32x32 -- perform addition of two 32-bit two's complement
 * integers.  This can result in overflow.  The lower 32 bits are
 * returned from this function, while the overflow/underflow is stored
 * in *hi (if hi is non-NULL). The *hi is set to 0 if the addition did
 * not overflow, 1 if it did, and -1 if it "underflowed".
 *
 * This function assumes that the actual representation for integers
 * is also 32-bit two's complement.  This algorithm can be generalized
 * to work with smaller integers, if necessary, but any representation
 * other than two's complement is going to cause major headaches.
 *
 */

int add32x32 (int a, int b, int *hi)
{
	int overflow;
	int sign_a	= (a >= 0) ? POSITIVE : NEGATIVE;
	int sign_b	= (b >= 0) ? POSITIVE : NEGATIVE;
	int lo		= a + b;
	int sign_lo	= (lo >= 0) ? POSITIVE : NEGATIVE;

	if (sign_a != sign_b) {
		overflow = 0;
	}
	else if (sign_a == POSITIVE && sign_lo == NEGATIVE) {
		overflow = 1;
	}
	else if (sign_a == NEGATIVE && sign_lo == POSITIVE) {
		overflow = -1;
	}
	else {
		overflow = 0;
	}

	if (hi != NULL) {
		*hi = overflow;
	}

	return (lo);
}

/*
 * add64x64 -- perform addition of two 64-bit two's complement
 * integers.  This can result in overflow, but it is ignored.
 *
 * The lower 32 bits are returned from this function, and the upper 32
 * bits in *hi (if hi is non-NULL).
 *
 * This function assumes that the actual representation for integers
 * is also 32-bit two's complement.  This algorithm can be generalized
 * to work with smaller integers, if necessary, but any representation
 * other than two's complement is going to cause major headaches.
 *
 */

int add64x64 (int a0, int a1, int b0, int b1, int *hi)
{
	int r0, r1;

	r0 = add32x32 (a0, b0, &r1);

	if (hi != NULL) {
		*hi = a1 + b1 + r1;
	}

	return (r0);
}

/*
 * sub32x32 -- perform subtraction of two 32-bit two's complement
 * integers.  This can result in overflow.  The lower 32 bits are
 * returned from this function, while the overflow/underflow is stored
 * in *hi (if hi is non-NULL).  The *hi is set to 0 if the subtraction
 * did not overflow, 1 if it did, and -1 if it "underflowed".
 *
 */

int sub32x32 (int a, int b, int *hi)
{
	int overflow;
	int sign_a	= (a >= 0) ? POSITIVE : NEGATIVE;
	int sign_b	= (b >= 0) ? POSITIVE : NEGATIVE;
	int lo		= a - b;
	int sign_lo	= (lo >= 0) ? POSITIVE : NEGATIVE;

	if (sign_a == sign_b) {
		overflow = 0;
	}
	else if (sign_a == POSITIVE && sign_lo == NEGATIVE) {
		overflow = 1;
	}
	else if (sign_a == NEGATIVE && sign_lo == POSITIVE) {
		overflow = -1;
	}
	else {
		overflow = 0;
	}

	if (hi != NULL) {
		*hi = overflow;
	}

	return (lo);
}

#ifdef	_TEST_
int test_funcs (long a, long b);

/*
 * This test rig assumes that it is running on 64-bit hardware, and
 * therefore the results of the native "long long" operations can be
 * compared to the 32-bit functions implemented here.
 */

int main (int argc, char **argv)
{
	int a, b;
	int i;

	/*
	 * First test some troublesome edge cases:
	 */

	test_funcs (MIN_INT32, MIN_INT32);

	test_funcs (MAX_INT32, MIN_INT32);
	test_funcs (MIN_INT32, MAX_INT32);

	test_funcs (MIN_INT32, 0);
	test_funcs (MIN_INT32, 0x1);
	test_funcs (MIN_INT32, 0xab);
	test_funcs (MIN_INT32, 0xabcd);
	test_funcs (MIN_INT32, 0xabcdef);

	test_funcs (0, MIN_INT32);
	test_funcs (0x1, MIN_INT32);
	test_funcs (0xab, MIN_INT32);
	test_funcs (0xabcd, MIN_INT32);
	test_funcs (0xabcdef, MIN_INT32);

	test_funcs (0, MAX_INT32);
	test_funcs (0x1, MAX_INT32);
	test_funcs (0xab, MAX_INT32);
	test_funcs (0xabcd, MAX_INT32);
	test_funcs (0xabcdef, MAX_INT32);

	for (i = 0; i < 10000000 ; i++) {

		a = rand () ^ (rand () << 8) ^ (rand () << 17);
		b = rand () ^ (rand () << 8) ^ (rand () << 17);

#ifdef	DEBUG
		if (i % 1000 == 0) {
			if (a > 0 && b > 0) {
				printf ("++");
			}
			else if (a > 0 || b > 0) {
				printf ("+-");
			}
			else {
				printf ("--");
			}

			if ((a > 1000000) && (b > 100000)) {
				printf ("0");
			}
			if ((a < -1000000) && (b < -100000)) {
				printf ("*");
			}
			printf ("\n");
		}
#endif	/* DEBUG */

		test_funcs (a, b);
	}

	exit (0);
}


int test_funcs (long a, long b)
{
	long long int add_ab;
	long long int sub_ab;
	long long int mul_ab;
	long long int mul_res;
	int add_hi, add_lo;
	int sub_hi, sub_lo;
	int mul_hi, mul_lo;
	int of;

	add_ab = (long long) a + (long long) b;
	add_lo = add32x32 (a, b, &add_hi);

	sub_ab = (long long) a - (long long) b;
	sub_lo = sub32x32 (a, b, &sub_hi);

	mul_ab = (long long) a * (long long) b;
	mul_lo = mul32x32 (a, b, &mul_hi);

	if (add_lo != (int) (0xffffffff & add_ab)) {
		printf ("\n%lx + %lx = wanted %llx, got %lx\n", a, b,
				add_ab, add_lo);
	}

	if (add_ab > MAX_INT32) {
		of = 1;
	}
	else if (add_ab < MIN_INT32) {
		of = -1;
	}
	else {
		of = 0;
	}

	if (add_hi != of) {
		printf ("\nhi %lx + %lx = wanted %lx, got %lx\n", a, b,
				of, add_hi);
	}

	if (sub_lo != (int) (0xffffffff & sub_ab)) {
		printf ("\n%lx - %lx = wanted %llx, got %lx\n", a, b,
				sub_ab, sub_lo);
	}

	if (sub_ab > MAX_INT32) {
		of = 1;
	}
	else if (sub_ab < MIN_INT32) {
		of = -1;
	}
	else {
		of = 0;
	}

	if (sub_hi != of) {
		printf ("\nhi %lx - %lx = wanted %lx, got %lx\n", a, b,
				of, sub_hi);
	}

	mul_res = (0xffffffff & mul_lo) | ((long long) mul_hi << 32);

	if (mul_res != mul_ab) {
		printf ("\n%lx * %lx = wanted %llx, got %llx\n", a, b,
				mul_ab, mul_res);
	}

	return (0);
}

#endif	/* _TEST_ */

/*
 * end of arith32.c
 */
