# Dan Ellard -- 03/15/2000
# print-3.asm-- Ant-8 code to print a string.
# Registers used:
# r2  - holds the address of the string
# r3  - holds the address of the end of the loop
# r4  - holds the next character to be printed.

        lc  r2, $first_str	# load the address of the first string into r2
	jmp $print_str		# jump to the print_str code
        lc  r2, $second_str	# load the address of the second string into r2
	jmp $print_str		# jump to the print_str code
	hlt

print_str:
        lc  r3, $end_print_loop	# load address of the end of the print loop
	add  r5, r1, r0
print_loop:
        ld1  r4, r2, 0		# Get the first character from the string
        beq  r3, r4, r0		# If the char is zero, we're finished.
        out  r4, ASCII		# Otherwise, print the character.
        inc  r2, 1		# Increment r2 to point to the next char
        jmp  $print_loop	# and repeat the process...
end_print_loop:
	beq  r5, r0, r0		# Jump back to the return address

_data_:

first_str:	.byte   'f', 'i', 'r', 's', 't', '\n', 0
second_str:	.byte   's', 'e', 'c', 'o', 'n', 'd', '\n', 0

# end of print-3.asm
