#
# Copyright 1999-2000 by the President and Fellows of Harvard College.
# See LICENSE.txt for license information.
#
#@ tests tlble, expects failure.
# OK

	lcl	r3, 400 	#out of range TLB index
	tlbse 	r6, r3		# try to get the TLB entry


