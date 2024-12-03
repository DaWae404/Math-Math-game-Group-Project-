.data
# Display Constants
.globl newLine    
newLine:    .asciiz "\n"
divider:    .asciiz " | "
hidden:     .asciiz " ? "

# Board Headers and Labels
board_header:    .asciiz "          1     2     3     4 "
one:        .asciiz "    1 "
two:        .asciiz "    2 "
three:      .asciiz "    3 "
four:       .asciiz "    4 "

# Board Template Components
board_separator:  .asciiz "       +-----+-----+-----+-----+ "
board_separator1: .asciiz "    1  |  ?  |  ?  |  ?  |  ?  | "
board_separator2: .asciiz "    2  |  ?  |  ?  |  ?  |  ?  | "
board_separator3: .asciiz "    3  |  ?  |  ?  |  ?  |  ?  | "
board_separator4: .asciiz "    4  |  ?  |  ?  |  ?  |  ?  | "

# Game Board Configurations
.align 2
board1: .asciiz 	"15 ", " 6 ", "12 ", "4x2",
		"2x2", "10 ", "5x5", "20 ",
		"2x5", " 4 ", "4x5", "3x2",
		"5x3", "25 ", " 8 ", "3x4"
.align 2
board2: .asciiz 	"5x5", "5x4", "16 ", "2x3",
		"3x3", "2x4", " 6 ", "20 ",
		"2x5", "25 ", "3x4", "12 ",
		" 8 ", "4x4", " 9 ", "10 "
.align 2
board3: .asciiz 	" 6 ", "3x5", "3x3", "2x2",
		"2x5", "2x3", "20 ", " 9 ",
		"15 ", "5x5", "10 ", "4x5",
		"12 ", " 4 ", "25 ", "4x3"
.align 2
board4: .asciiz 	"20 ", "4x3", "4x4", "12 ",
		"5x3", "16 ", "5x4", " 9 ",
		"5x2", "2x4", "10 ", "2x2",
		"15 ", " 4 ", " 8 ", "3x3"

# Solution Values
.globl board1_values
board1_values: .word 15, 6, 12, 8, 4, 10, 25, 20, 10, 4, 20, 6, 15, 25, 8, 12
.globl board2_values
board2_values: .word 25, 20, 16, 6, 9, 8, 6, 20, 10, 25, 12, 12, 8, 16, 9, 10
.globl board3_values
board3_values: .word 6, 15, 9, 4, 10, 6, 20, 9, 15, 25, 10, 20, 12, 4, 25, 12
.globl board4_values
board4_values: .word 20, 12, 16, 12, 15, 16, 20, 9, 10, 8, 10, 4, 15, 4, 8, 9

# Game State Storage
.align 2
currentToPrint: .asciiz "     "

.globl board_state
.align 2
board_state: .space 64    # Active board state

.globl board_matched
board_matched: .word '?','?','?','?',    # Hidden cards
                     '?','?','?','?',    
                     '?','?','?','?',    
                     '?','?','?','?'     

.globl index1, index2
index1: .word 0    # First selection index
index2: .word 0    # Second selection index

.globl thisGameAnswers
thisGameAnswers: .space 64    # Current solutions

.globl current_guess1, current_guess2
current_guess1: .word -1    # First guess (-1 = none)
current_guess2: .word -1    # Second guess (-1 = none)

.text
# Board Initialization Function
.globl initialize_board
initialize_board:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    # Random board selection
    addi $a1, $zero, 4
    addi $v0, $zero, 42
    syscall         
    
    li   $t0, 0                    
    li   $t1, 1                    
    li   $t2, 2
    li   $t3, 3                                            
    sw   $a0, board_current_num
    
    # Board selection logic
    beq  $a0, $t0, load_board1
    beq  $a0, $t1, load_board2
    beq  $a0, $t2, load_board3            
    beq  $a0, $t3, load_board4   

# Board Loading Functions
load_board1:
    la   $s1, board1
    li   $t3, 0
    j    copy_board

load_board2:
    la   $s1, board2    
    li   $t3, 1
    j    copy_board

load_board3:
    la   $s1, board3    
    li   $t3, 2
    j    copy_board

load_board4:
    la   $s1, board4    
    li   $t3, 3
    j    copy_board    

# Board Copying Function
copy_board:
    la   $s0, board_state
    li   $t1, 0
    
copy_loop:
    sll  $t2, $t1, 2
    add  $t3, $s1, $t2
    add  $t4, $s0, $t2
    lw   $t0, ($t3)
    sw   $t0, ($t4)
    addi $t1, $t1, 1
    blt  $t1, 16, copy_loop

# Initial Board Display Function
print_initial_grid:
    # Header
    jal  print_board_header
    
    # Row 1
    jal  print_row_one
    
    # Row 2
    jal  print_row_two
    
    # Row 3
    jal  print_row_three
    
    # Row 4
    jal  print_row_four
    
    # Bottom border
    
    move $v0, $t3
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# Board Update Function
.globl updatedBoard 
updatedBoard:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
     
    # Update matched cards
    lw   $t6, index1
    lw   $t7, index2
    lw   $t4, board_state($t6)
    lw   $t5, board_state($t7)
    sw   $t4, board_matched($t6)
    sw   $t5, board_matched($t7)
    
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# Board Display Function
.globl display_board
display_board:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s1, 20($sp)
    sw   $s2, 16($sp)
    sw   $s3, 12($sp)
    sw   $s4, 8($sp)
    sw   $s5, 4($sp)
    sw   $s6, 0($sp)
    
    # Print header
    jal print_board_header
    
    # Initialize row counter
    li   $s1, 0

display_row_loop:
    li   $v0, 4
    beq  $s1, 0, print_row1
    beq  $s1, 1, print_row2
    beq  $s1, 2, print_row3
    beq  $s1, 3, print_row4
    
display_continue_row:
    li   $s2, 0   # Column counter

display_column_loop:
    # Calculate card index
    move $s3, $s1
    mul  $s3, $s3, 16
    move $t4, $s2
    mul  $t4, $t4, 4
    add  $s3, $s3, $t4

    # Print divider
    li   $v0, 4
    la   $a0, divider
    syscall

    # Check card visibility
    lw   $t2, current_guess1
    lw   $t3, current_guess2
    beq  $s3, $t2, display_card
    beq  $s3, $t3, display_card
    
    # Check if matched
    la   $t0, board_matched
    add  $t0, $t0, $s3
    lw   $t1, ($t0)
    bne  $t1, '?', display_card
    
    # Show hidden card
    li   $v0, 4
    la   $a0, hidden
    syscall 
    j    display_continue_column 
    
display_card:
    la   $t0, board_state
    add  $t0, $t0, $s3
    lw   $t1, ($t0)
    sw   $t1, currentToPrint
    li   $v0, 4
    la   $a0, currentToPrint
    syscall
    
display_continue_column:
    addi $s2, $s2, 1
    blt  $s2, 4, display_column_loop
                            
    # End row
    jal  print_row_end
    
    # Next row
    addi $s1, $s1, 1
    blt  $s1, 4, display_row_loop
    
    # Cleanup and return
    lw   $s6, 0($sp)
    lw   $s5, 4($sp)
    lw   $s4, 8($sp)
    lw   $s3, 12($sp)
    lw   $s2, 16($sp)
    lw   $s1, 20($sp)
    lw   $ra, 24($sp)
    addi $sp, $sp, 28
    jr   $ra 

# Helper Functions for Board Display
print_board_header:
    li   $v0, 4
    la   $a0, board_header
    syscall
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_row_end:
    li   $v0, 4
    la   $a0, divider
    syscall 
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_row_one:
    li   $v0, 4
    la   $a0, board_separator1
    syscall
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_row_two:
    li   $v0, 4
    la   $a0, board_separator2
    syscall
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_row_three:
    li   $v0, 4
    la   $a0, board_separator3
    syscall
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_row_four:
    li   $v0, 4
    la   $a0, board_separator4
    syscall
    la   $a0, newLine
    syscall
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

print_bottom_border:
    li   $v0, 4
    la   $a0, board_separator
    syscall
    la   $a0, newLine
    syscall
    jr   $ra

# Row Label Functions
print_row1:
    la   $a0, one
    syscall
    j    display_continue_row
    
print_row2:
    la   $a0, two
    syscall
    j    display_continue_row

print_row3:
    la   $a0, three
    syscall
    j    display_continue_row
    
print_row4:
    la   $a0, four
    syscall
    j    display_continue_row
