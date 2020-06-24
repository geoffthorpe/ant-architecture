# $Id: echo.asm,v 1.2 2000/11/22 00:29:59 ellard Exp $
#
# Barney Titmouse - 11/10/96
#
# Echos input.
#
# See cat.asm for the same basic program, coded
# in a slightly different style.
#
# Register usage:
#
# r2 - holds each character read in.
# r3 - address of $print.
#

	lc	r3, $print

loop:
	sys	r2, 0x6		# r2 = getchar ();
	beq	r3, r1, r0	# if not at EOF, go to $print.
	jmp	$exit		# otherwise, go to $exit.

print:  
	sys	r2, 0x3		# putchar (r2);
	jmp	$loop		# iterate, go back to $loop

exit:
	sys	r0, 0		# just halt; nothing else to do.

# end of echo.asm
