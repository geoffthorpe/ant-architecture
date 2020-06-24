# Dan Ellard -- 03/15/2000
# print-1.asm-- Ant-8 code to print a string.
# Registers used:
# r2  - holds the address of the string
# r3  - holds the address of the end of the loop
# r4  - holds the next character to be printed.

        lc      r2, $first_str  # load the address of the string into r2
        lc      r3, $endloop1   # load address of the end of loop 1.
loop1:
        ld1     r4, r2, 0       # Get the first character from the string
        beq     r3, r4, r0      # If the char is zero, we're finished.
        out	r4, ASCII       # Otherwise, print the character.
        inc     r2, 1           # Increment r2 to point to the next char
        jmp     $loop1          # and repeat the process...
endloop1:

        lc      r2, $second_str # load the address of the string into r2
        lc      r3, $endloop2   # load address of the end of loop 2.
loop2:
        ld1     r4, r2, 0       # Get the first character from the string
        beq     r3, r4, r0      # If the char is zero, we're finished.
        out	r4, ASCII       # Otherwise, print the character.
        inc     r2, 1           # Increment r2 to point to the next char
        jmp     $loop2          # and repeat the process...
endloop2:
        hlt

_data_:                         # Data for the program begins here:
 
first_str:	.byte   'f', 'i', 'r', 's', 't', '\n', 0
second_str:	.byte   's', 'e', 'c', 'o', 'n', 'd', '\n', 0

# end of print-1.asm
