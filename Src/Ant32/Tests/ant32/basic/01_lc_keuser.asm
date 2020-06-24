#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests lc
# OK
	lc r2, $start
	cli
	cle
	rfe r2, r0, r0
start:
	lc k3, 15
	lc k2, 15
	lc k1, 15
	lc k0, 15
	lc e3, 15
	lc e2, 15
	lc e1, 15
	lc e0, 15

	stop
