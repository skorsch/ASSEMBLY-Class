# UVic CSC 230, Summer 2020
# Assignment #1, part B

# Student name: Sabrina Korsch
# Student number: V00847425


# Compute the reverse of the input bit sequence that must be stored
# in register $8, and the reverse must be in register $15.


.text
start:
	lw $8, testcase3   # STUDENTS MAY MODIFY THE TESTCASE GIVEN IN THIS LINE
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


	add $9, $0, $0			# $9 is a counter for going along the bit sequence of $8
	add $15, $0, $0			#$15 will hold the mirrored sequence
	addi $20, $0, 31		#check for when to end loop 
	
	
loop2:
	andi $11, $8, 1			#take the rightmost bit of $8 and put into $11
	beq $11, $0, unset_bit		#if bit is unset skip the bit transfer
	addi $15, $15, 1		#otherwise bit is set so add one to the mirror seq
					
unset_bit:
						
	sll $15, $15, 1			#then shift $15 left logical
	srl $8, $8, 1			#shift $8 right logical
	addi $9, $9, 1			#counter + 1
	bne $9, $20, loop2 		#if counter = $20 then exit
	
					
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

exit:
	add $2, $0, 10
	syscall
	
	

.data

testcase1:
	.word	0x00200020    # reverse is 0x04000400	

testcase2:
	.word 	0x00300020    # reverse is 0x04000c00
	
testcase3:
	.word	0xdecafbad	#0x1234fedc     # reverse is 0x3b7f2c48
