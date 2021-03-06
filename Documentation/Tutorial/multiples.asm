# Dan Ellard -- 11/2/96
# multiples.asm-- An Ant-8 program that takes two
#	numbers A and B, and prints out
#       all the multiples of A from A to A * B.
#       If B <= 0, then no multiples are printed.
# Registers used:
# r2 - used to hold A.
# r3 - used to hold B.
# r4 - used to store top, the sentinel value A * B.
# r5 - used to store multiple, the current multiple of A.
# r6 - used for address of labels
# r7 - used for holding and printing spaces and a newline

start:
        in      r2, Hex			# read A into r2 (as hex)
        in      r3, Hex			# read B into r3 (as hex)

        lc      r6, $halt               # r6 = the address of halt.
        beq     r6, r2, r0              # of A == 0, halt.
A_ok:
        lc      r6, $B_ok               # r6 = the address of B_ok.
        bgt     r6, r3, r0              # make sure that B > 0.
        hlt      			# if B <= 0, exit.
B_ok:
        mul     r4, r2, r3              # top = A * B.
        add     r5, r2, r0              # multiple = A  
loop:
        out     r5, Hex			# print out multiple (r5) in hex 

        lc      r6, $endloop            # r6 = the address of endloop
        beq     r6, r4, r5              # if multiple == top, we're done.
        add     r5, r5, r2              # otherwise, multiple += A.

        lc      r7, ' '
        out     r7, ASCII		# print an ASCII space 

        jmp     $loop                   # go to top of the loop
endloop:
        lc      r7, '\n'
        out	r7, ASCII		# print an ASCII newline
        
halt:
        hlt      			# Exit   

# end of multiples.asm
