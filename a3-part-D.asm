# This code assumes the use of the "Bitmap Display" tool.
#
# Tool settings must be:
#   Unit Width in Pixels: 32
#   Unit Height in Pixels: 32
#   Display Width in Pixels: 512
#   Display Height in Pixels: 512
#   Based Address for display: 0x10010000 (static data)
#
# In effect, this produces a bitmap display of 16x16 pixels.


	.include "bitmap-routines.asm"

	.data
TELL_TALE:
	.word 0x12345678 0x9abcdef0	# Helps us visually detect where our part starts in .data section
KEYBOARD_EVENT_PENDING:
	.word	0x0
KEYBOARD_EVENT:
	.word   0x0
BOX_ROW:
	.word	0x0
BOX_COLUMN:
	.word	0x0

	.eqv LETTER_a 97
	.eqv LETTER_d 100
	.eqv LETTER_w 119
	.eqv LETTER_x 120
	.eqv BOX_COLOUR 0x0099ff33
	
	.globl main
	
	.text	
main:
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	
	#the following 4 lines are taken from lab since they are related to setting up the keyboard simulator
	la $s0, 0xffff0000	# control register for MMIO Simulator "Receiver"
	lb $s1, 0($s0)
	ori $s1, $s1, 0x02	# Set bit 1 to enable "Receiver" interrupts (i.e., keyboard)
	sb $s1, 0($s0)

	# initialize variables
	addi $a0, $zero, 0
	addi $a1, $zero, 0
	addi $a2, $zero, 0x0099ff33
	addi $sp, $sp, -8	#store MMIO values since this method uses these registers
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	jal draw_bitmap_box
	lw $s0, 0($sp)		#restore
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
check_for_event:
	la $s2, KEYBOARD_EVENT_PENDING
	lw $s3, 0($s2)
	beq $s3, $zero, check_for_event #check for event loops until keyboard event pend is not zero
	
	#start of keyboard event
	la $s4, KEYBOARD_EVENT
	lw $s5, 0($s4)		#loads in value of keyboard event
	lw $a0, BOX_ROW
	lw $a1, BOX_COLUMN
	
	addi $sp, $sp, -8	#store MMIO values since these registers will get used
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	beq $s5, 97, key_a	#a was pressed
	beq $s5, 100, key_d	#d was pressed
	beq $s5, 119, key_w	#w was pressed
	beq $s5, 120, key_x	#x was pressed
	#something else was pressed and does not effect the program so exit 
	beq $zero, $zero, exit
	
key_a:
	addi $a2, $zero, 0x00000000	#clear current box
	jal draw_bitmap_box	#don't need to protect any regs for this call since the ones in use aren't called within it
	
	addi $a1, $a1, -1	#change column value and draw new box
	sw $a1, BOX_COLUMN	#store it
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	beq $zero, $zero, exit	

key_d:	#same as key_but adds 1 to column
	addi $a2, $zero, 0x00000000	
	jal draw_bitmap_box	
	
	addi $a1, $a1, 1	#change column value and draw new box
	sw $a1, BOX_COLUMN	
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	beq $zero, $zero, exit

key_w:	#same as key_but adds -1 to row
	addi $a2, $zero, 0x00000000	
	jal draw_bitmap_box	
	
	addi $a0, $a0, -1	#change row value and draw new box
	sw $a0, BOX_ROW	
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	beq $zero, $zero, exit

key_x:	#same as key_but adds 1 to row
	addi $a2, $zero, 0x00000000	
	jal draw_bitmap_box	
	
	addi $a0, $a0, 1	#change row value and draw new box
	sw $a0, BOX_ROW	
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	beq $zero, $zero, exit

exit:
	lw $s0, 0($sp)		#restore MMIO registers
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	sw $zero, KEYBOARD_EVENT_PENDING	#continue prev loop by setting pending to zero
	beq $zero, $zero, check_for_event
	
	
	# Should never, *ever* arrive at this point
	# in the code.	

	addi $v0, $zero, 10
	syscall



# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

draw_bitmap_box:
#
# You can copy-and-paste some of your code from part (c)
# to provide the procedure body.
#
	addi $s0, $zero, 4 	#keeps track of rows to pixel
row_loop:
	addi $s1, $zero, 4	#keeps track of columns to pixel
column_loop:	#sets every pixel within a row (nested for loop)
	addi $sp, $sp -28	#store all arguments just in case the method alters them
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	
	jal set_pixel	#fill in pixel
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)	#restore values
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	addi $sp, $sp 28
	
	addi $a1, $a1, 1		#go to next column
	addi $s1, $s1, -1	#decrement loop
	bne $s1, $zero, column_loop
	
	addi $a0, $a0, 1	#go to next row
	addi $a1, $a1, -4	#reset column position
	addi $s0, $s0, -1	#decrement loop
	bne $s0, $zero, row_loop
	
	addi $a0, $a0, -4	#reset row position
	jr $ra


	.kdata

	.ktext 0x80000180
#
# You can copy-and-paste some of your code from part (a)
# to provide elements of the interrupt handler.
#
__kernel_entry:	#TAKEN FROM LAB (not sure how you would write these any different)
	mfc0 $k0, $13		
	andi $k1, $k0, 0x7c	
	srl  $k1, $k1, 2	
	beq $zero, $k1, __is_interrupt	
	
__is_exception: #TAKEN FROM LAB
	#kinda catchall exception
	beq $zero, $zero, __exit_exception
	
__is_interrupt:	#TAKEN FROM LAB 
	andi $k1, $k0, 0x0100	
	bne $k1, $zero, __is_keyboard_interrupt	 
	
	beq $zero, $zero, __exit_exception	
	
__is_keyboard_interrupt:
	la $k0, 0xffff0004	#loads address of keypress into $k0
	lw $k1, 0($k0)		#loads value at that address
	sw $k1, KEYBOARD_EVENT	#stores the keypress value into keyboard event mem space
	addi $k0, $zero, 1
	sw $k0, KEYBOARD_EVENT_PENDING	#stores 1 into this mem space to indicate a keypress happened for non kernel code
	
__exit_exception:
	eret


.data

# Any additional .text area "variables" that you need can
# be added in this spot. The assembler will ensure that whatever
# directives appear here will be placed in memory following the
# data items at the top of this file.

	
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
	
