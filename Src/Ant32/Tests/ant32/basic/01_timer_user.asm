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
	lc r3, 10
	timer r0, r3
	stop
