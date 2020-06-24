# Dan Ellard - 11/10/96
# Echos input until EOF.
# Register usage:
# r2 - holds each character read in.
# r3 - address of $print.

        lc      r3, $print
loop:
        sys     r2, SysGetChar  # r2 = getchar ();
        beq     r3, r1, r0      # if not at EOF, go to $print.
        jmp     $exit           # otherwise, go to $exit.
print:
        sys     r2, SysPutChar  # putchar (r2);
        jmp     $loop           # iterate, go back to $loop.
exit:
        sys     r0, SysHalt     # Exit

# end of echo.asm
