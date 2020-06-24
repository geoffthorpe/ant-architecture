/*
 * $Id: ant32_reg.c,v 1.5 2002/05/20 19:15:54 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 10/25/01
 *
 */

#include	<stdio.h>

#include	"ant_external.h"
#include	"ant32_external.h"

static int check_names (ant_asm_str_id_t *name_set);

/*
 * Yucko!  A global variable!
 *
 * Quick and dirty strikes again.
 */
 
static	ant_asm_str_id_t	reg_names []	= {
	{ "r0",  0 }, { "r1",  1 }, { "r2",  2 }, { "r3",  3 },
	{ "r4",  4 }, { "r5",  5 }, { "r6",  6 }, { "r7",  7 },
	{ "r8",  8 }, { "r9",  9 }, { "r10",10 }, { "r11",11 },
	{ "r12",12 }, { "r13",13 }, { "r14",14 }, { "r15",15 },
	{ "r16",16 }, { "r17",17 }, { "r18",18 }, { "r19",19 },
	{ "r20",20 }, { "r21",21 }, { "r22",22 }, { "r23",23 },
	{ "r24",24 }, { "r25",25 }, { "r26",26 }, { "r27",27 },
	{ "r28",28 }, { "r29",29 }, { "r30",30 }, { "r31",31 },
	{ "r32",32 }, { "r33",33 }, { "r34",34 }, { "r35",35 },
	{ "r36",36 }, { "r37",37 }, { "r38",38 }, { "r39",39 },
	{ "r40",40 }, { "r41",41 },
	{ "r42",42 }, { "r43",43 }, { "r44",44 }, { "r45",45 },
	{ "r46",46 }, { "r47",47 }, { "r48",48 }, { "r49",49 },
	{ "r50",50 }, { "r51",51 },
	{ "r52",52 }, { "r53",53 }, { "r54",54 }, { "r55",55 },
	{ "r56",56 }, { "r57",57 }, { "r58",58 }, { "r59",59 },
	{ "r60",60 }, { "r61",61 },
	{ "r62",62 }, { "r63",63 },
	{ NULL,	 0 }
};

static	ant_asm_str_id_t	special_reg_names []	= {
	{ "c0", 240},		/* Cycle counters.	*/
	{ "c1", 241},
	{ "c2", 242},
	{ "c3", 243},
	{ "c4", 244},
	{ "c5", 245},
	{ "c6", 246},
	{ "c7", 247},
	{ "k0", 248},		/* Kernel scratch	*/
	{ "k1", 249},
	{ "k2", 250},
	{ "k3", 251},
	{ "e0", 252},		/* Exception registers	*/
	{ "e1", 253},
	{ "e2", 254},
	{ "e3", 255},
	{ NULL, 0}
};

static	ant_asm_str_id_t	mnemonic_s_reg_names []	= {
	{ "ze",   0 }, { "ra",   1 }, { "sp",   2 }, { "fp",   3 },
	{ "u0",  60 }, { "u1",  61 }, { "u2",  62 }, { "u3",  63 },
	{ NULL,   0 }
};

static	ant_asm_str_id_t	mnemonic_g_reg_names [] = {
	{ "g0",   4 }, { "g1",   5 }, { "g2",   6 }, { "g3",   7 },
	{ "g4",   8 }, { "g5",   9 }, { "g6",  10 }, { "g7",  11 },
	{ "g8",  12 }, { "g9",  13 }, { "g10", 14 }, { "g11", 15 },
	{ "g12", 16 }, { "g13", 17 }, { "g14", 18 }, { "g15", 19 },
	{ "g16", 20 }, { "g17", 21 }, { "g18", 22 }, { "g19", 23 },
	{ "g20", 24 }, { "g21", 25 }, { "g22", 26 }, { "g23", 27 },
	{ "g24", 28 }, { "g25", 29 }, { "g26", 30 }, { "g27", 31 },
	{ "g28", 32 }, { "g29", 33 }, { "g30", 34 }, { "g31", 35 },
	{ "g32", 36 }, { "g33", 37 }, { "g34", 38 }, { "g35", 39 },
	{ "g36", 40 }, { "g37", 41 }, { "g38", 42 }, { "g39", 43 },
	{ "g40", 44 }, { "g41", 45 }, { "g42", 46 }, { "g43", 47 },
	{ "g44", 48 }, { "g45", 49 }, { "g46", 50 }, { "g47", 51 },
	{ "g48", 52 }, { "g49", 53 }, { "g50", 54 }, { "g51", 55 },
	{ "g52", 56 }, { "g53", 57 }, { "g54", 58 }, { "g55", 59 },

	{ NULL,   0 }
};

static	ant_asm_str_id_t	mnemonic_c_reg_names []	= {
	{ "v0",   4 }, { "v1",   5 },
	
	{ "a0",   6 }, { "a1",   7 },
	{ "a2",   8 }, { "a3",   9 }, { "a4",  10 }, { "a5",  11 },

	{ "s0",  12 }, { "s1",  13 }, { "s2",  14 }, { "s3",  15 },
	{ "s4",  16 }, { "s5",  17 }, { "s6",  18 }, { "s7",  19 },
	{ "s8",  20 }, { "s9",  21 }, { "s10", 22 }, { "s11", 23 },
	{ "s12", 24 }, { "s13", 25 }, { "s14", 26 }, { "s15", 27 },
	{ "s16", 28 }, { "s17", 29 }, { "s18", 30 }, { "s19", 31 },
	{ "s20", 32 }, { "s21", 33 }, { "s22", 34 }, { "s23", 35 },

	{ "t0",  36 }, { "t1",  37 }, { "t2",  38 }, { "t3",  39 },
	{ "t4",  40 }, { "t5",  41 }, { "t6",  42 }, { "t7",  43 },
	{ "t8",  44 }, { "t9",  45 }, { "t10", 46 }, { "t11", 47 },
	{ "t12", 48 }, { "t13", 49 }, { "t14", 50 }, { "t15", 51 },
	{ "t16", 52 }, { "t17", 53 }, { "t18", 54 }, { "t19", 55 },
	{ "t20", 56 }, { "t21", 57 }, { "t22", 58 }, { "t23", 59 },

	{ NULL,   0 }
};

static int check_names (ant_asm_str_id_t *name_set)
{
	static int barked = 0;
	static int seen_r = 0;
	static int seen_g = 0;
	static int seen_s = 0;
	static int seen_c = 0;

	if (barked) {
		return (0);
	}

	if (name_set == reg_names) {
		seen_r = 1;
		if (seen_g || seen_s || seen_c) {
			barked = 1;
			printf ("ERROR: change of register naming conventions!\n");
			return (-1);
		}
	}
	else if (name_set == mnemonic_s_reg_names) {
		seen_s = 1;

		if (seen_r) {
			barked = 1;
			printf ("ERROR: change of register naming conventions!\n");
			return (-1);
		}
	}
	else if (name_set == mnemonic_g_reg_names) {
		seen_g = 1;

		if (seen_r || seen_c) {
			barked = 1;
			printf ("ERROR: change of register naming conventions!\n");
			return (-1);
		}
	}

	else if (name_set == mnemonic_c_reg_names) {
		seen_c = 1;

		if (seen_r || seen_g) {
			barked = 1;
			printf ("ERROR: change of register naming conventions!\n");

			return (-1);
		}
	}

	return (0);
}

int ant_find_reg (char *str, unsigned int len)
{
	int i;

	if ((i = match_str_id (str, len, reg_names)) >= 0) {
		if (check_names (reg_names)) return (-1);
		return (reg_names [i].id);
	}
	else if ((i = match_str_id (str, len, mnemonic_s_reg_names)) >= 0) {
		if (check_names (mnemonic_s_reg_names)) return (-1);
		return (mnemonic_s_reg_names [i].id);
	}
	else if ((i = match_str_id (str, len, mnemonic_g_reg_names)) >= 0) {
		if (check_names (mnemonic_g_reg_names)) return (-1);
		return (mnemonic_g_reg_names [i].id);
	}
	else if ((i = match_str_id (str, len, mnemonic_c_reg_names)) >= 0) {
		if (check_names (mnemonic_c_reg_names)) return (-1);
		return (mnemonic_c_reg_names [i].id);
	}
	else if ((i = match_str_id (str, len, special_reg_names)) >= 0) {
		return (special_reg_names [i].id);
	}
	else {
		return (-1);
	}
}

/*
 * end of ant32_reg.c
 */
