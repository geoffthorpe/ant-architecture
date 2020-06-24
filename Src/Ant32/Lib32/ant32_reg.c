/*
 * $Id: ant32_reg.c,v 1.2 2002/01/02 02:29:18 ellard Exp $
 *
 * Copyright 1996-2001 by the President and Fellows of Harvard College.
 * See LICENSE.txt for license information.
 *
 * Dan Ellard -- 11/09/01
 *
 * ant32_reg.c -- register naming convention boilerplate.  Ulch.
 */

static	char	*regNamesR [64] = {
	"r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",  "r8",  "r9",
	"r10", "r11", "r12", "r13", "r14", "r15", "r16", "r17", "r18", "r19",
	"r20", "r21", "r22", "r23", "r24", "r25", "r26", "r27", "r28", "r29",
	"r30", "r31", "r32", "r33", "r34", "r35", "r36", "r37", "r38", "r39",
	"r40", "r41", "r42", "r43", "r44", "r45", "r46", "r47", "r48", "r49",
	"r50", "r51", "r52", "r53", "r54", "r55", "r56", "r57", "r58", "r59",
	"r60", "r61", "r62", "r63"
};

static	char	*regNamesG [64] = {
	"ze",  "ra",  "sp",  "fp",
	"g0",  "g1",  "g2",  "g3",  "g4",  "g5",  "g6",  "g7",  "g8",  "g9",
	"g10", "g11", "g12", "g13", "g14", "g15", "g16", "g17", "g18", "g19",
	"g20", "g21", "g22", "g23", "g24", "g25", "g26", "g27", "g28", "g29",
	"g30", "g31", "g32", "g33", "g34", "g35", "g36", "g37", "g38", "g39",
	"g40", "g41", "g42", "g43", "g44", "g45", "g46", "g47", "g48", "g49",
	"g50", "g51", "g52", "g53", "g54", "g55",
	"u0",  "u1",  "u2",  "u3"
};

static	char	*regNamesC [64] = {
	"ze",  "ra",  "sp",  "fp",
	"v0",  "v1",
	"a0",  "a1",  "a2",  "a3",  "a4",  "a5",
	"s0",  "s1",  "s2",  "s3",  "s4",  "s5",  "s6",  "s7",  "s8",  "s9",
	"s10", "s11", "s12", "s13", "s14", "s15", "s16", "s17", "s18", "s19",
	"s20", "s21", "s22", "s23",
	"t0",  "t1",  "t2",  "t3",  "t4",  "t5",  "t6",  "t7",  "t8",  "t9",
	"t10", "t11", "t12", "t13", "t14", "t15", "t16", "t17", "t18", "t19",
	"t20", "t21", "t22", "t23",
	"u0",  "u1",  "u2",  "u3"
};

static	char	**regNames	= regNamesG;
	int	regNamesType	= 'g';

int ant32_reg_names_change (int names)
{

	switch (names) {
		case 'c' :
			regNamesType = names;
			regNames = regNamesC;
			return (0);
			break;
		case 'g' :
			regNamesType = names;
			regNames = regNamesG;
			return (0);
			break;
		case 'r' :
			regNamesType = names;
			regNames = regNamesR;
			return (0);
			break;
		default  :
			return (-1);
			break;
	}
}

char *ant32_reg_name (unsigned int reg)
{

	if (reg < 64) {
		return (regNames [reg]);
	}
	else {
		switch (reg) {
			case 240 : return ("c0"); break;
			case 241 : return ("c1"); break;
			case 242 : return ("c2"); break;
			case 243 : return ("c3"); break;
			case 244 : return ("c4"); break;
			case 245 : return ("c5"); break;
			case 246 : return ("c6"); break;
			case 247 : return ("c7"); break;
			case 248 : return ("k0"); break;
			case 249 : return ("k1"); break;
			case 250 : return ("k2"); break;
			case 251 : return ("k3"); break;
			case 252 : return ("e0"); break;
			case 253 : return ("e1"); break;
			case 254 : return ("e2"); break;
			case 255 : return ("e3"); break;
			default  : return ("NAR"); break;
		}
	}
}

/*
 * end of ant32_reg.c
 */
