
	.data
ARRAY_A:
	.word	21, 210, 49, 4
ARRAY_B:
	.word	21, -314159, 0x1000, 0x7fffffff, 3, 1, 4, 1, 5, 9, 2
ARRAY_Z:
	.space	28
NEWLINE:
	.asciiz "\n"
SPACE:
	.asciiz " "
		
	
	.text  
main:	
	la $a0, ARRAY_A
	addi $a1, $zero, 4
	jal dump_array
	
	la $a0, ARRAY_B
	addi $a1, $zero, 11
	jal dump_array
	
	la $a0, ARRAY_Z
	lw $t0, 0($a0)
	addi $t0, $t0, 1
	sw $t0, 0($a0)
	addi $a1, $zero, 9
	jal dump_array
		
	addi $v0, $zero, 10
	syscall

# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	#prints out intergers using syscall with spaces in between , then a newline at the end
dump_array:
	add $t0, $zero, $a0	#store a0 in a diff reg since the syscall will use it, could store on stack but this is a bit simpler for this case
loop:
	beq $a1, $zero, end_loop	#start check for zero
	beq $a1, 1, print_no_space	#makes sure not to print an extra space if only one int
	lw $a0, 0($t0)		#load int at current address into a0
	addi $v0, $zero, 1	#load instruc for printing int into v0
	syscall 		#prints out int
	
	la $a0, SPACE		#print a space 
	addi $v0, $zero, 4
	syscall
	
	addi $t0, $t0, 4 	#goes to next int, increment address by 4
	addi $a1, $a1, -1	#decrement int count
	bne $a1, 1, loop	#loop if not equal to zero

#prints last int without a space at end, wasn't explicitly stated in assignment but the typed example doesn't have one at the end of a line
print_no_space:
	lw $a0, 0($t0)		#load int at current address into a0
	addi $v0, $zero, 1	#load instruc for printing int into v0
	syscall 		#prints out int
	
end_loop:
	la $a0, NEWLINE		#print newline
	addi $v0, $zero, 4
	syscall
	jr $ra
	
	
	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
