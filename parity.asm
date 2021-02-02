# UVic CSC 230, Summer 2020
# Assignment #1, part A

# Student name: Sabrina Korsch
# Student number: V00847425


# Compute even parity of word that must be in register $8
# Value of even parity (0 or 1) must be in register $15


.text

start:
	lw $8, testcase3  # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	add $9, $0, $0			# $9 is a counter for going along the bit sequence of $8
	add $10, $0, $0			# $10 is a counter for how many bits are set
	addi $20, $0, 33		#check for when to end loop
loop:
	andi $11, $8, 1			#take the rightmost bit of $8
	beq $11, $0, unset_bit		#if bit is unset skip the counter
	addi $10, $10, 1		#bit is set so add one to set bit count
				
unset_bit:				
	addi $9, $9, 1			#counter + 1
	srl $8, $8, 1			#shift right logical $8 so we can analyze next bit
	bne $9, $20, loop		#if sequence counter != 32 then keep looping
	
	andi $12, $10, 1		#take rightmost bit of $10 (how many bits are set)
	beq $12, $0, set_parity_0	#if rightmost bit is zero set the parity value to zero, since all even numbers end in an unset bit
	addi $15, $0, 1			#otherwise set the parity value to 1 and exit, since odd numbers end in a set bit
	beq $0, $0, exit
	
set_parity_0:
	add $15, $0, $0			#sets oarity bit to zero
					


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE


exit:
	add $2, $0, 10
	syscall
		

.data

testcase1:
	.word	0x00200020    # even parity is 0

testcase2:
	.word 	0x00300020    # even parity is 1
	
testcase3:
	.word  0x1234fedc     # even parity is is 1

