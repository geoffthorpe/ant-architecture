# Dan Ellard
# echo.asm - An Ant-32 program that echos input until EOI
#	(End of Input) is reached.
# g0 - holds each character read in.
# g1 - address of $print.
# g2 - scratch.

        lc      g1, $print
loop:
	# We've reached End of Input when g0 gets -1.  To check for
	# -1, add 1 to g0 and check to see if the result is zero.

        cin     g0              # g0 = getchar ();
	addi	g2, g0, 1	# Looking for -1...
        jnz     ze, g2, g1      # if not at EOI, go to $print.
        j       $exit           # otherwise, go to $exit.
print:
        cout    g0		# putchar (g0);
        j       $loop           # iterate, go back to $loop.
exit:
        halt                    # Exit
