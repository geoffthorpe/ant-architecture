# $Id$
#
# boot.asm:
#

	1. Initialize sp, fp, ra.
	2. Initialize leh.
	3. Jump to the base of the real code.

	4. Code for exception handling stuff.

# Standard memory map:
#
#	1 meg of physical RAM.
#	boot.asm lives in last page.
#	stack starts and end of second-to-last page.

