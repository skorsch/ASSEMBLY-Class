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
	
	.globl main
	.text	
main:
	addi $a0, $zero, 0
	addi $a1, $zero, 0
	addi $a2, $zero, 0x00ff0000
	jal draw_bitmap_box
	
	addi $a0, $zero, 11
	addi $a1, $zero, 6
	addi $a2, $zero, 0x00ffff00
	jal draw_bitmap_box
	
	addi $a0, $zero, 8
	addi $a1, $zero, 8
	addi $a2, $zero, 0x0099ff33
	jal draw_bitmap_box
	
	addi $a0, $zero, 2
	addi $a1, $zero, 3
	addi $a2, $zero, 0x00000000
	jal draw_bitmap_box

	addi $v0, $zero, 10
	syscall
	
# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


# Draws a 4x4 pixel box in the "Bitmap Display" tool
# $a0: row of box's upper-left corner
# $a1: column of box's upper-left corner
# $a2: colour of box

draw_bitmap_box:
	addi $s0, $zero, 4 	#keeps track of rows to pixel

row_loop:
	addi $s1, $zero, 4	#keeps track of columns to pixel
column_loop:	#sets every pixel within a row (nested for loop)
	addi $sp, $sp -24	#store all arguments just in case the method alters them
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	
	jal set_pixel	#fill in pixel
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)	#restore values
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	addi $sp, $sp 24
	
	addi $a1, $a1, 1		#go to next column
	addi $s1, $s1, -1	#decrement loop
	bne $s1, $zero, column_loop
	
	addi $a0, $a0, 1	#go to next row
	addi $a1, $a1, -4	#reset column position
	addi $s0, $s0, -1	#decrement loop
	bne $s0, $zero, row_loop
	
	addi $a0, $a0, -4	#reset row position (not really needed, but is for next part)
	jr $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE
