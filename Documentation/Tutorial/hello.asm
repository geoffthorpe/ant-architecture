# Dan Ellard -- 01/19/2000
# hello.asm-- An Ant-8 "Hello World" program.
# Registers used:
# r2  - holds the address of the string
# r3  - holds the address of the end of the loop
# r4  - holds the next character to be printed.

        lc      r2, $str_data   # load the address of the string into r2
        lc      r3, $endloop    # load address of the end of loop.

loop:
        ld1     r4, r2, 0       # Get the first character from the string
        beq     r3, r4, r0      # If the char is zero, we're finished.
        out	r4, ASCII       # Otherwise, print the character.
        inc     r2, 1           # Increment r2 to point to the next char
        jmp     $loop           # and repeat the process...

endloop:
        hlt

_data_:                         # Data for the program begins here:
 
str_data: 
        .byte   'H', 'e', 'l', 'l', 'o', ' '
        .byte   'W', 'o', 'r', 'l', 'd', '\n', 0

# end of hello.asm
