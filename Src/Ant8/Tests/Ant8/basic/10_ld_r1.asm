# $Id: 10_ld_r1.asm,v 1.2 2001/03/22 00:39:03 ellard Exp $
#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ Tests basic ld1 functionality for r1
# OK

	lc r2, $a

	ld1 r1, r2, 0

	hlt

_data_:

a:
	.byte	000, 001, 002, 003, 004, 005, 006, 007
	.byte	010, 011, 012, 013, 014, 015, 016, 017
	.byte	020, 021, 022, 023, 024, 025, 026, 027
	.byte	030, 031, 032, 033, 034, 035, 036, 037
