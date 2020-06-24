# Dan Ellard - 11/10/96
# echo.asm - An Ant-8 program that echos input until EOI is reached.
# Register usage:
# r2 - holds each character read in.
# r3 - address of $print.

        lc      r3, $print
loop:
        in      r2, ASCII       # r2 = getchar ();
        beq     r3, r1, r0      # if not at EOF, go to $print.
        jmp     $exit           # otherwise, go to $exit.
print:
        out     r2, ASCII	# putchar (r2);
        jmp     $loop           # iterate, go back to $loop.
exit:
        hlt                     # Exit

# end of echo.asm
