.data
# Game Messages and Prompts
prompt_first_card:       .asciiz "Please flip your first card by entering the row number and the column number (for example: 11 (row 1 column 1)): "
prompt_second_card:      .asciiz "Please flip your second card: "
match_success_msg:       .asciiz "\nYou have found a match!\n"
match_fail_msg:         .asciiz "\nNot a match. Try again!\n"
wrong_guess:            .asciiz "Wrong guess!! Please Try again!\n"
invalid_input:          .asciiz "Invalid input! Please try again\n"
duplicated_guess_error: .asciiz "Please do not choose the same cards. Try again!"

# Input Buffers and Game State
bufffer_input1:         .space 16    # First card buffer
bufffer_input2:         .space 16    # Second card buffer
.globl board_current_num
board_current_num:      .word 0      # Active board tracker

.text
.globl gameLoop

# Main Game Loop
gameLoop:
    # Stack Frame Setup
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $t0, 4($sp)
    sw   $t1, 8($sp)
    sw   $v0, 12($sp)
    sw   $a0, 16($sp)

card_select_first:
    # Reset guesses
    li $t0, -1
    sw $t0, current_guess1
    sw $t0, current_guess2

    # Display new line
    li $v0, 4
    la $a0, newLine
    syscall

    # Prompt for first card
    li $v0, 4
    la $a0, prompt_first_card
    syscall

    # Read first input
    li $v0, 8
    la $a0, bufffer_input1
    li $a1, 16
    syscall

    # Validate first input
    la $a0, bufffer_input1
    jal card_validate_position
    beqz $v0, invalid_input_handler1

    # Convert and store first card
    la $a0, bufffer_input1
    jal convert_input_to_index
    sw $v0, index1
    sw $v0, current_guess1

    # Display new line
    li $v0, 4
    la $a0, newLine
    syscall

    # Show board
    jal display_board

card_select_second:
    # Display new line
    li $v0, 4
    la $a0, newLine
    syscall

    # Prompt for second card
    li $v0, 4
    la $a0, prompt_second_card
    syscall

    # Read second input
    li $v0, 8
    la $a0, bufffer_input2
    li $a1, 16
    syscall

    # Validate second input
    la $a0, bufffer_input2
    jal card_validate_position
    beqz $v0, invalid_input_handler2

    # Convert and store second card
    la $a0, bufffer_input2
    jal convert_input_to_index
    sw $v0, index2
    sw $v0, current_guess2

    # Check for duplicate selection
    lw $t0, current_guess1
    lw $t1, current_guess2
    beq $t0, $t1, repeated_guess_handler

    # Display new line and board
    li $v0, 4
    la $a0, newLine
    syscall
    
    jal display_board

    li $v0, 4
    la $a0, newLine
    syscall

    # Check for match
    jal check_card_match
    beqz $v0, position_invalid

    # Handle successful match
    li $v0, 4
    la $a0, match_success_msg
    syscall

    jal updatedBoard
    j continue_game

position_invalid:
    li $v0, 4
    la $a0, match_fail_msg
    syscall

continue_game:
    jal check_game_complete
    bnez $v0, game_handle_victory
    j gameLoop

# Error Handlers
invalid_input_handler1:
    li $v0, 4
    la $a0, newLine
    syscall
    
    li $v0, 4
    la $a0, invalid_input
    syscall
    
    j card_select_first

invalid_input_handler2:
    li $v0, 4
    la $a0, newLine
    syscall
    
    li $v0, 4
    la $a0, invalid_input
    syscall
    
    j card_select_second

repeated_guess_handler:
    li $v0, 4
    la $a0, newLine
    syscall
    
    li $v0, 4
    la $a0, duplicated_guess_error
    syscall
    
    li $v0, 4
    la $a0, newLine
    syscall
    
    j card_select_first
    
   
# Helper Functions for Card Selection
reset_guesses:
    li $t0, -1
    sw $t0, current_guess1
    sw $t0, current_guess2
    jr $ra

get_card_selection:
    # Preserve registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $v0, 8($sp)
    sw $a0, 4($sp)
    sw $a1, 0($sp)
    
    # Print newline
    li $v0, 4
    la $a0, newLine
    syscall
    
    # Print prompt
    li $v0, 4
    lw $a0, 4($sp)
    syscall
    
    # Get input
    li $v0, 8
    lw $a0, 0($sp)
    li $a1, 16
    syscall
    
    # Validate input
    lw $a0, 0($sp)
    jal card_validate_position
    beqz $v0, get_card_selection_end
    
    # Convert valid input to index
    lw $a0, 0($sp)
    jal convert_input_to_index
    sw $v0, 8($sp)          # Save the converted index

get_card_selection_end:
    # Restore registers and return
    lw $v0, 8($sp)
    lw $ra, 12($sp)
    lw $a0, 4($sp)
    lw $a1, 0($sp)
    addi $sp, $sp, 16
    jr $ra

store_first_card:
    # Preserve registers
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    # Store card index
    sw $s0, index1
    sw $s0, current_guess1
    
    # Update display
    li $v0, 4
    la $a0, newLine
    syscall
    jal display_board
    
    # Restore registers and return
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

store_second_card:
    # Preserve registers
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    # Store card index
    sw $s0, index2
    sw $s0, current_guess2
    
    # Check for duplicate selection
    lw $t0, current_guess1
    lw $t1, current_guess2
    beq $t0, $t1, handle_duplicate_selection
    
    # Update display
    li $v0, 4
    la $a0, newLine
    syscall
    jal display_board
    li $v0, 4
    la $a0, newLine
    syscall
    
    # Restore registers and return
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    jr $ra

handle_duplicate_selection:
    # Restore registers before jumping
    lw $ra, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 8
    j repeated_guess_handler

process_card_match:
    # Preserve return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Check for match
    jal check_card_match
    beqz $v0, show_match_fail
    
    # Handle successful match
    li $v0, 4
    la $a0, match_success_msg
    syscall
    jal updatedBoard
    j process_card_match_end
    
show_match_fail:
    li $v0, 4
    la $a0, match_fail_msg
    syscall
    
process_card_match_end:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Card Processing Functions
convert_input_to_index:
    lb $t0, 0($a0)        # Row
    lb $t1, 1($a0)        # Column
    
    li $t2, '1'
    sub $t0, $t0, $t2
    mul $t0, $t0, 16      # Row offset
    
    sub $t1, $t1, $t2
    mul $t1, $t1, 4       # Column offset
    
    add $v0, $t0, $t1     # Combined index
    jr $ra

# Match Checking Functions
check_card_match:
    lw $t0, index1
    lw $t1, index2
    lw $t2, board_current_num
    
    beqz $t2, load_board1
    li $t3, 1
    beq $t2, $t3, load_board2
    li $t3, 2
    beq $t2, $t3, load_board3
    j load_board4

load_answers:
    add $t4, $t3, $t0
    lw $t4, 0($t4)
    add $t5, $t3, $t1
    lw $t5, 0($t5)
    
    seq $v0, $t4, $t5
    jr $ra

load_board1:
    la $t3, board1_values
    j load_answers

load_board2:
    la $t3, board2_values
    j load_answers

load_board3:
    la $t3, board3_values
    j load_answers

load_board4:
    la $t3, board4_values
    j load_answers

# Game State Check
check_game_complete:
    la $t0, board_matched
    li $t1, 0
    li $t2, 16

check_loop:
    lw $t3, ($t0)
    beq $t3, '?', incomplete_game
    addi $t1, $t1, 1
    addi $t0, $t0, 4
    bne $t1, $t2, check_loop
    
    li $v0, 1
    jr $ra

incomplete_game:
    li $v0, 0
    jr $ra