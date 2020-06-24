# cat.ant: copy stdin to stdout 1 char at a time
#
# See echo.asm for the same basic program, coded
# in a slightly different style.
#
# registers:
#       r14: -1
#       r2: input char

        lc      r14, $skip
loop:
        sys     r2, 6                   # r2 = getchar()
        beq     r14, r1, r0             # if !EOF skip over goto end
        jmp     $end			# EOF => go to end
skip:
        sys     r2, 3                   # putchar(r2)
        jmp     $loop			# read next char
end:
        sys     r0, 0                   # halt

