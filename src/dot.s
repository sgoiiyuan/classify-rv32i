.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    li t0, 1              # Check if element count >= 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   # Check if stride0 >= 1
    blt a4, t0, error_terminate   # Check if stride1 >= 1

    li t0, 0              # Initialize dot product result to 0
    li t1, 0              # Initialize index i to 0

    slli a3, a3, 2
    slli a4, a4, 2
    addi sp, sp, -4      # Adjust stack pointer to make space
    sw ra, 0(sp)         # Store ra on the stack
loop_start:
    # TODO: Add your own implementation
    addi t1, t1, 1
    lw t2 ,0(a0)    # First input array
    lw t3 ,0(a1)    # Second input array

    jal multiplier

    add t0, t0, t4  # Result + dot
    add a0, a0, a3  # Skip distance in first array
    add a1, a1, a4  # Skip distance in second array
    blt t1, a2, loop_start

loop_end:
    mv a0, t0
    lw ra, 0(sp)         # Load original ra from stack
    addi sp, sp, 4       # Restore stack pointe
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit

multiplier:
    # Initialize result to 0
    li t5, 0            # t5 will hold the result (product)

    # Loop through each bit of b
mul_loop_start:
    # Check if b is zero, if so, we're done
    beqz t3, mul_loop_end    # If b == 0, exit the loop

    # If the least significant bit of b is 1, add a to the result
    andi t6, t3, 1       # t6 = b & 1 (check the least significant bit of b)
    beqz t6, mul_skip_addition    # If the bit is 0, skip addition

    add t5, t5, t2       # result += a (add a to the result)

mul_skip_addition:
    # Shift a left by 1 (multiply a by 2)
    slli t2, t2, 1       # a = a * 2 (left shift by 1)

    # Shift b right by 1 (divide b by 2)
    srli t3, t3, 1       # b = b / 2 (right shift by 1, arithmetic shift)

    # Repeat the loop
    j mul_loop_start

mul_loop_end:
    # Return the result in a0
    mv t4, t5            # Copy result to t4 for return
    jr ra