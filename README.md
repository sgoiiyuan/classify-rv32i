# Assignment 2: Classify

# Assignment2: Complete Applications

## Project Overview
This project challenges us to develop a simple yet highly practical system using **RISC-V assembly language**. Throughout the process, we will explore essential low-level programming concepts, such as:

* Efficient use of registers for optimized code execution.
* Writing functions and adhering to RISC-V calling conventions for both internal and external functions.
* Memory management by allocating space on the stack and heap.
* Pointer manipulation for working with matrix and vector data structures.

To make the project engaging, we will implement various matrix and vector operations, such as matrix multiplication. These functions will serve as the building blocks for constructing a simple [Artificial Neural Network](https://en.wikipedia.org/wiki/Neural_network_(machine_learning)) (ANN) capable of classifying handwritten digits. Through this exercise, we will observe how ANNs can be implemented using basic numerical operations like vector inner products, matrix multiplications, and non-linear thresholding.

## Part A: Mathematical Functions
In this section, we will implement essential matrix operations used in neural networks. Specifically, we’ll create functions for dot product, matrix multiplication, element-wise ReLU, and argmax.

### Task 1: ReLU
In `relu.s`, implement the ReLU function, which applies the transformation:
$$
ReLU(a) = \max(a, 0)
$$
Each element of the input array will be individually processed by setting negative values to 0. Since the matrix is stored as a **1D row-major vector**, this function operates directly on the flattened array.

Use `test_relu.s` to set up and run tests on your ReLU function. You can define the matrix values in static memory, and the test will print the matrix before and after applying ReLU.

`relu.s`:
```s
.globl relu       

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified (base address of the array).
#   a1: Number of elements in the array (size of the array).
#
# Returns:
#   None - The original array is modified in-place.
#
# Validation:
#   - Ensures the array has at least one element (a1 ≥ 1).
#   - If validation fails, the program terminates with code 36.
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================

relu:
    li t0, 1              # Load immediate value 1 into register t0 (minimum array length allowed).
    blt a1, t0, error     # If a1 < 1, jump to the error handler (invalid array length).
    li t1, 0              # Load immediate value 0 into t1 (used as the comparison value for ReLU).

loop_start:
    beqz a1, return       # If a1 (remaining elements) is 0, jump to the return block (end of function).
    lw t3, 0(a0)          # Load the current array element into t3 (dereference the pointer in a0).
    blt t3, t1, set_zero  # If t3 (current element) < 0, jump to set_zero to replace it with 0.
    j next_element        # Otherwise, skip to the next element in the array.

set_zero:
    sw t1, 0(a0)          # Store the value 0 (in t1) back into the current array element.

next_element:
    addi a0, a0, 4        # Move the pointer (a0) to the next array element (increment by 4 bytes).
    addi a1, a1, -1       # Decrement the counter (a1) to process one less element.
    j loop_start          # Jump back to the start of the loop.

return:
    jr ra                 # Return to the caller by jumping to the address in the return address register (ra).

error:
    li a0, 36             # Load the exit code 36 into a0 (error code for invalid input).
    j exit                # Jump to the exit label (terminates the program).

```
### Task 2: ArgMax
In `argmax.s`, implement the argmax function, which returns the index of the largest element in a given vector. If multiple elements share the largest value, return the smallest index. This function operates on 1D vectors.

Use `test_argmax.s` to test the function. You can modify the static vector and its length in the test file. Running the test will print the index of the largest element.

`argmax.s`:
```s
.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)

    li t1, 0
    li t2, 1
    
loop_start:
    addi a0, a0, 4        # Move the pointer to the next element in the array
    bge t2, a1, done      # If the index t2 reaches the array length, exit the loop
    lw t3, 0(a0)          # Load the current element of the array into t3

    bge t3, t0, update_max # If current element t3 is >= max value (t0), update max value

next_element:
    addi t2, t2, 1        # Increment the index
    j loop_start          # Continue to the next element

update_max:
    addi t0, t3, 0        # Update max value to current element (t3)
    addi t1, t2, 0        # Update the index of the max value
    j next_element        # Continue to the next element

done:
    addi a0, t1, 0        # Return the index of the first maximum element
    jr ra                 # Return from function

handle_error:
    li a0, 36
    j exit
```
### Task 3.1: Dot Product
In `dot.s`, implement the dot product function, defined as:
$$
dot(a, b) = \sum_{i=0}^{n-1} a_i b_i
$$
You will need to account for stride when accessing the vector elements. No overflow handling is required, so you will not need the `mulh` instruction.

Fill out `test_dot.s` using the provided starter code to test your dot product function.

`dot.s`:
```s
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

```
```s
multiplier:
    # Initialize result to 0
    li t5, 0                      # t5 will hold the result (product)

# Loop through each bit of b
mul_loop_start:
    # Check if b is zero, if so, we're done
    beqz t3, mul_loop_end         # If b == 0, exit the loop

    # If the least significant bit of b is 1, add a to the result
    andi t6, t3, 1                # t6 = b & 1 (check the least significant bit of b)
    beqz t6, mul_skip_addition    # If the bit is 0, skip addition

    add t5, t5, t2                # result += a (add a to the result)

mul_skip_addition:
    # Shift a left by 1 (multiply a by 2)
    slli t2, t2, 1                # a = a * 2 (left shift by 1)

    # Shift b right by 1 (divide b by 2)
    srli t3, t3, 1                # b = b / 2 (right shift by 1, arithmetic shift)

    j mul_loop_start              # Repeat the loop

mul_loop_end:
    # Return the result in a0
    mv t4, t5                     # Copy result to t4 for return
    jr ra
```
### Task 3.2: Matrix Multiplication
In `matmul.s`, implement matrix multiplication, where:
$$
C[i][j] = dot(A[i], B[:, j])
$$

Given matrices $A$ (size $n$ x $m$) and $B$ (size $m$ x $k$), the output matrix $C$ will have dimensions $n$ x $k$.

* Rows of matrix $A$ will have stride = 1.
* Columns of matrix $B$ will require calculating the correct starting index and stride.

If the dimensions of the matrices are incompatible, the program should exit with code 4.

Use `test_matmul.s` to test your matrix multiplication.

`matmul.s`:
```s
.globl matmul     

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count
#     a2: Column count
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count
#     a5: Column count
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation (in sequence):
#   1. Validates M0: Ensures positive dimensions
#   2. Validates M1: Ensures positive dimensions
#   3. Validates multiplication compatibility: M0_cols = M1_rows
#   All failures trigger program exit with code 38.
#
# Output:
#   None explicit - Result matrix D populated in-place.
# =======================================================

matmul:
    # Validation of input matrices' dimensions
    li t0, 1               # Load immediate value 1 (minimum valid dimension).
    blt a1, t0, error      # If rows0 < 1, jump to error.
    blt a2, t0, error      # If cols0 < 1, jump to error.
    blt a4, t0, error      # If rows1 < 1, jump to error.
    blt a5, t0, error      # If cols1 < 1, jump to error.
    bne a2, a4, error      # If cols0 != rows1, jump to error (incompatible matrices).

    # Prologue: Save caller-saved registers to stack
    addi sp, sp, -28       # Allocate 28 bytes of stack space.
    sw ra, 0(sp)           # Save return address.
    sw s0, 4(sp)           # Save s0 register.
    sw s1, 8(sp)           # Save s1 register.
    sw s2, 12(sp)          # Save s2 register.
    sw s3, 16(sp)          # Save s3 register.
    sw s4, 20(sp)          # Save s4 register.
    sw s5, 24(sp)          # Save s5 register.

    # Initialize loop variables and pointers
    li s0, 0               # Initialize outer loop counter (rows of M0).
    li s1, 0               # Initialize inner loop counter (columns of M1).
    mv s2, a6              # Set result matrix pointer (D).
    mv s3, a0              # Set M0 pointer.
    mv s4, a3              # Set M1 pointer.

outer_loop_start:
    # Outer loop processes rows of M0
    li s1, 0               # Reset inner loop counter for each row of M0.
    mv s4, a3              # Reset M1 pointer for each new row in M0.
    blt s0, a1, inner_loop_start # Continue if s0 < rows0.
    j outer_loop_end       # Exit if all rows of M0 are processed.

inner_loop_start:
    # Inner loop processes columns of M1
    beq s1, a5, inner_loop_end  # Exit inner loop if all columns are processed.

    # Dot product of M0 row and M1 column
    addi sp, sp, -24       # Allocate stack for temporary values.
    sw a0, 0(sp)           # Save a0.
    sw a1, 4(sp)           # Save a1.
    sw a2, 8(sp)           # Save a2.
    sw a3, 12(sp)          # Save a3.
    sw a4, 16(sp)          # Save a4.
    sw a5, 20(sp)          # Save a5.

    mv a0, s3              # Set M0 row pointer for dot product function.
    mv a1, s4              # Set M1 column pointer for dot product function.
    mv a2, a2              # Set number of elements (cols0/rows1).
    li a3, 1               # Set stride for M0 (row traversal).
    mv a4, a5              # Set stride for M1 (column traversal).
    jal dot                # Call dot product helper function.

    mv t0, a0              # Store result of dot product in t0.
    lw a0, 0(sp)           # Restore a0.
    lw a1, 4(sp)           # Restore a1.
    lw a2, 8(sp)           # Restore a2.
    lw a3, 12(sp)          # Restore a3.
    lw a4, 16(sp)          # Restore a4.
    lw a5, 20(sp)          # Restore a5.
    addi sp, sp, 24        # Deallocate stack.

    sw t0, 0(s2)           # Store dot product result in result matrix.
    addi s2, s2, 4         # Move result matrix pointer to next element.
    li t1, 4
    add s4, s4, t1         # Move M1 column pointer to the next column.
    addi s1, s1, 1         # Increment inner loop counter.
    j inner_loop_start     # Continue inner loop.

inner_loop_end:
    # End of inner loop: Move to the next row of M0
    addi s0, s0, 1         # Increment outer loop counter.
    slli t0, a2, 2         # Calculate row offset in M0 (cols0 × 4 bytes).
    add s3, s3, t0         # Move M0 pointer to the next row.
    j outer_loop_start     # Restart outer loop.

outer_loop_end:
    # Epilogue: Restore caller-saved registers and return
    lw ra, 0(sp)           # Restore return address.
    lw s0, 4(sp)           # Restore s0 register.
    lw s1, 8(sp)           # Restore s1 register.
    lw s2, 12(sp)          # Restore s2 register.
    lw s3, 16(sp)          # Restore s3 register.
    lw s4, 20(sp)          # Restore s4 register.
    lw s5, 24(sp)          # Restore s5 register.
    addi sp, sp, 28        # Deallocate stack.
    jr ra                  # Return to caller.

error:
    li a0, 38              # Load error code 38 into a0.
    j exit                 # Jump to exit routine.

```
## Part B: File Operations and Main
This section focuses on reading and writing matrices to files and building the main function to perform digit classification using the pretrained MNIST weights.

### Task 1: Read Matrix
In `read_matrix.s`, implement the function to **read a binary matrix** from a file and load it into memory. If any file operation fails, exit with the following codes:

* 48: Malloc error
* 50: fopen error
* 51: fread error
* 52: fclose error

`read_matrix.s`:
```s
.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Binary Matrix File Reader
#
# Loads matrix data from a binary file into dynamically allocated memory.
# Matrix dimensions are read from file header and stored at provided addresses.
#
# Binary File Format:
#   Header (8 bytes):
#     - Bytes 0-3: Number of rows (int32)
#     - Bytes 4-7: Number of columns (int32)
#   Data:
#     - Subsequent 4-byte blocks: Matrix elements
#     - Stored in row-major order: [row0|row1|row2|...]
#
# Arguments:
#   Input:
#     a0: Pointer to filename string
#     a1: Address to write row count
#     a2: Address to write column count
#
#   Output:
#     a0: Base address of loaded matrix
#
# Error Handling:
#   Program terminates with:
#   - Code 26: Dynamic memory allocation failed
#   - Code 27: File access error (open/EOF)
#   - Code 28: File closure error
#   - Code 29: Data read error
#
# Memory Note:
#   Caller is responsible for freeing returned matrix pointer
# ==============================================================================
read_matrix:

    # Prologue: Set up stack frame and save registers
    addi sp, sp, -40         # Allocate space on stack
    sw ra, 0(sp)             # Save return address
    sw s0, 4(sp)             # Save register s0
    sw s1, 8(sp)             # Save register s1
    sw s2, 12(sp)            # Save register s2
    sw s3, 16(sp)            # Save register s3
    sw s4, 20(sp)            # Save register s4

    mv s3, a1                # Copy row count address to s3
    mv s4, a2                # Copy column count address to s4

    li a1, 0                 # Initialize file open flag to 0

    jal fopen                # Call fopen to open the file

    li t0, -1
    beq a0, t0, fopen_error  # If fopen failed, jump to error handling

    mv s0, a0                # Store file pointer in s0

    # Read rows and columns from the file header (8 bytes)
    mv a0, s0                # File pointer in a0
    addi a1, sp, 28          # Buffer address in a1
    li a2, 8                 # Read 8 bytes (for rows and columns)
    jal fread                # Read data from file

    li t0, 8
    bne a0, t0, fread_error  # If fread didn't read 8 bytes, jump to error

    # Retrieve the number of rows and columns from the buffer
    lw t1, 28(sp)            # Load row count into t1
    lw t2, 32(sp)            # Load column count into t2

    sw t1, 0(s3)             # Store number of rows in memory location pointed by s3
    sw t2, 0(s4)             # Store number of columns in memory location pointed by s4

    # Calculate number of elements in the matrix (rows * columns)
    # NOTE: Using a custom multiplication loop to avoid using 'mul'
    # We use bitwise shifts and additions to perform multiplication
    multiplier:
    li t5, 0                 # Initialize result to 0

    # Loop through each bit of column count (t2) for multiplication
    mul_loop_start:
        beqz t2, mul_loop_end    # If column count is zero, exit loop

        andi t6, t2, 1           # Check least significant bit of column count (t2)
        beqz t6, mul_skip_addition    # If it's 0, skip addition step

        add t5, t5, t1           # Add row count (t1) to result

    mul_skip_addition:
        slli t1, t1, 1           # Multiply row count by 2 (shift left)
        srli t2, t2, 1           # Divide column count by 2 (shift right)
        j mul_loop_start         # Repeat loop

    mul_loop_end:
        mv s1, t5                # Store result in s1 (number of elements)

    # Calculate the total size in bytes (number of elements * size of int)
    slli t3, s1, 2             # Multiply number of elements by 4 (size of int)
    sw t3, 24(sp)              # Store size in bytes in stack

    lw a0, 24(sp)              # Load size in bytes into a0
    jal malloc                 # Allocate memory for matrix

    beq a0, x0, malloc_error   # If malloc failed, jump to error handling

    mv s2, a0                  # Store allocated memory address in s2 (matrix base address)

    # Read matrix data from the file
    mv a0, s0                  # File pointer in a0
    mv a1, s2                  # Matrix pointer in a1 (destination)
    lw a2, 24(sp)              # Matrix size in bytes (number of elements * 4)
    jal fread                  # Read matrix data into allocated memory

    lw t3, 24(sp)              # Load expected size in bytes
    bne a0, t3, fread_error    # If fread didn't read expected bytes, jump to error

    mv a0, s0                  # File pointer in a0
    jal fclose                 # Close the file

    li t0, -1
    beq a0, t0, fclose_error   # If fclose failed, jump to error handling

    mv a0, s2                  # Return the matrix base address in a0

    # Epilogue: Restore saved registers and return
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore register s0
    lw s1, 8(sp)               # Restore register s1
    lw s2, 12(sp)              # Restore register s2
    lw s3, 16(sp)              # Restore register s3
    lw s4, 20(sp)              # Restore register s4
    addi sp, sp, 40            # Restore stack pointer

    jr ra                      # Return to caller

# Error handling for malloc failure
malloc_error:
    li a0, 26                  # Error code for malloc failure
    j error_exit               # Jump to exit with error

# Error handling for file open failure
fopen_error:
    li a0, 27                  # Error code for fopen failure
    j error_exit               # Jump to exit with error

# Error handling for fread failure
fread_error:
    li a0, 29                  # Error code for fread failure
    j error_exit               # Jump to exit with error

# Error handling for fclose failure
fclose_error:
    li a0, 28                  # Error code for fclose failure
    j error_exit               # Jump to exit with error

# Exit function with error code
error_exit:
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore register s0
    lw s1, 8(sp)               # Restore register s1
    lw s2, 12(sp)              # Restore register s2
    lw s3, 16(sp)              # Restore register s3
    lw s4, 20(sp)              # Restore register s4
    addi sp, sp, 40            # Restore stack pointer
    j exit                     # Jump to exit


```
### Task 2: Write Matrix
In `write_matrix.s`, implement the function to **write a matrix to a binary file**. Use the following exit codes for errors:

* 53: fopen error
* 54: fwrite error
* 55: fclose error

`write_matrix.s`:
```s
.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue: Save the registers that will be used in the function.
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # Save the arguments for later use
    mv s1, a1        # s1 = matrix pointer (starting address of the matrix)
    mv s2, a2        # s2 = number of rows in the matrix
    mv s3, a3        # s3 = number of columns in the matrix

    li a1, 1         # Set file mode to write (1)
    
    # Open the file for writing, a0 will hold the file pointer if successful
    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # If fopen failed (a0 = -1), jump to fopen_error

    mv s0, a0        # s0 = file descriptor (file pointer)

    # Write the number of rows and columns to the file (8 bytes)
    sw s2, 24(sp)    # Store number of rows at sp+24
    sw s3, 28(sp)    # Store number of columns at sp+28

    mv a0, s0        # Load file pointer into a0
    addi a1, sp, 24  # Address of the buffer containing row and column data
    li a2, 2         # Number of elements to write (rows and columns)
    li a3, 4         # Size of each element (4 bytes for integer)

    # Write number of rows and columns to the file
    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error  # If fwrite failed (not writing exactly 2 elements), jump to fwrite_error

    # Multiply number of rows and columns to get total number of elements
    # Replacing 'mul' instruction with custom multiplication function

    # Initialize result to 0 (this will hold the number of elements)
    li t5, 0            # t5 will hold the result (product)

    # Loop to multiply the number of rows and columns
mul_loop_start:
    # Check if columns (s3) is zero, if so, we're done
    beqz s3, mul_loop_end    # If s3 == 0, exit the loop

    # If the least significant bit of s3 is 1, add rows (s2) to the result
    andi t6, s3, 1       # t6 = s3 & 1 (check the least significant bit of s3)
    beqz t6, mul_skip_addition    # If bit is 0, skip addition

    add t5, t5, s2       # result += rows (s2)

mul_skip_addition:
    # Shift s2 left by 1 (multiply rows by 2)
    slli s2, s2, 1       # s2 = s2 * 2 (left shift by 1)

    # Shift s3 right by 1 (divide columns by 2)
    srli s3, s3, 1       # s3 = s3 / 2 (right shift by 1)

    # Repeat the loop
    j mul_loop_start

mul_loop_end:
    # Store the result (total elements) in s4
    mv s4, t5            # Copy result to s4 for return

    # Write matrix data to the file
    mv a0, s0            # File pointer in a0
    mv a1, s1            # Matrix data pointer in a1
    mv a2, s4            # Number of elements (total matrix elements) in a2
    li a3, 4             # Size of each element in bytes

    # Write the matrix data to the file
    jal fwrite

    bne a0, s4, fwrite_error  # If fwrite failed, jump to fwrite_error

    mv a0, s0            # Prepare for fclose

    # Close the file
    jal fclose

    li t0, -1
    beq a0, t0, fclose_error  # If fclose failed, jump to fclose_error

    # Epilogue: Restore saved registers and return from function
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra

# Error handling: handle different error cases

fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

# Exit function after error handling
error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit

```
### Task 3: Classification
In `classify.s`, bring everything together to classify an input using two weight matrices and the ReLU and ArgMax functions.

`classify.s`:
```s
.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
# Description:
#   Command line program for matrix-based classification
#
# Command Line Arguments:
#   1. M0_PATH      - First matrix file location
#   2. M1_PATH      - Second matrix file location
#   3. INPUT_PATH   - Input matrix file location
#   4. OUTPUT_PATH  - Output file destination
#
# Register Usage:
#   a0 (int)        - Input: Argument count
#                   - Output: Classification result
#   a1 (char **)    - Input: Argument vector
#   a2 (int)        - Input: Silent mode flag
#                     (0 = verbose, 1 = silent)
#
# Error Codes:
#   31 - Invalid argument count
#   26 - Memory allocation failure
#
# Usage Example:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prolouge
    addi sp, sp, -48
    
    sw ra, 0(sp)
    
    sw s0, 4(sp) # m0 matrix
    sw s1, 8(sp) # m1 matrix
    sw s2, 12(sp) # input matrix
    
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
     
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s3, a0 # save m0 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s4, a0 # save m0 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 4(a1) # set argument 1 for the read_matrix function  
    mv a1, s3 # set argument 2 for the read_matrix function
    mv a2, s4 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s0, a0 # setting s0 to the m0, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12
    # Read pretrained m1
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s5, a0 # save m1 rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s6, a0 # save m1 cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 8(a1) # set argument 1 for the read_matrix function  
    mv a1, s5 # set argument 2 for the read_matrix function
    mv a2, s6 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s1, a0 # setting s1 to the m1, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Read input matrix
    
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, rows
    beq a0, x0, error_malloc
    mv s7, a0 # save input rows pointer for later
    
    li a0, 4
    jal malloc # malloc 4 bytes for an integer, cols
    beq a0, x0, error_malloc
    mv s8, a0 # save input cols pointer for later
    
    lw a1, 4(sp) # restores the argument pointer
    
    lw a0, 12(a1) # set argument 1 for the read_matrix function  
    mv a1, s7 # set argument 2 for the read_matrix function
    mv a2, s8 # set argument 3 for the read_matrix function
    
    jal read_matrix
    
    mv s2, a0 # setting s2 to the input matrix, aka the return value of read_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation

    multiplier_1:
    # Initialize result to 0
    li t5, 0            # t5 will hold the result (product)

        # Loop through each bit of b
    mul_loop_start_1:
        # Check if b is zero, if so, we're done
        beqz t1, mul_loop_end_1    # If b == 0, exit the loop

        # If the least significant bit of b is 1, add a to the result
        andi t6, t1, 1       # t6 = b & 1 (check the least significant bit of b)
        beqz t6, mul_skip_addition_1    # If the bit is 0, skip addition

        add t5, t5, t0       # result += a (add a to the result)

    mul_skip_addition_1:
        # Shift a left by 1 (multiply a by 2)
        slli t0, t0, 1       # a = a * 2 (left shift by 1)

        # Shift b right by 1 (divide b by 2)
        srli t1, t1, 1       # b = b / 2 (right shift by 1, arithmetic shift)

        # Repeat the loop
        j mul_loop_start_1

    mul_loop_end_1:
        # Return the result in a0
        mv a0, t5            # Copy result to t4 for return

    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0 # move h to s9
    
    mv a6, a0 # h 
    
    mv a0, s0 # move m0 array to first arg
    lw a1, 0(s3) # move m0 rows to second arg
    lw a2, 0(s4) # move m0 cols to third arg
    
    mv a3, s2 # move input array to fourth arg
    lw a4, 0(s7) # move input rows to fifth arg
    lw a5, 0(s8) # move input cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Compute h = relu(h)
    addi sp, sp, -8
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9 # move h to the first argument
    lw t0, 0(s3)
    lw t1, 0(s8)
    # mul a1, t0, t1 # length of h array and set it as second argument
    # FIXME: Replace 'mul' with your own implementation
    
    multiplier_2:
    # Initialize result to 0
    li t5, 0            # t5 will hold the result (product)

        # Loop through each bit of b
    mul_loop_start_2:
        # Check if b is zero, if so, we're done
        beqz t1, mul_loop_end_2    # If b == 0, exit the loop

        # If the least significant bit of b is 1, add a to the result
        andi t6, t1, 1       # t6 = b & 1 (check the least significant bit of b)
        beqz t6, mul_skip_addition_2    # If the bit is 0, skip addition

        add t5, t5, t0       # result += a (add a to the result)

    mul_skip_addition_2:
        # Shift a left by 1 (multiply a by 2)
        slli t0, t0, 1       # a = a * 2 (left shift by 1)

        # Shift b right by 1 (divide b by 2)
        srli t1, t1, 1       # b = b / 2 (right shift by 1, arithmetic shift)

        # Repeat the loop
        j mul_loop_start_2

    mul_loop_end_2:
        # Return the result in a0
        mv a1, t5            # Copy result to t4 for return

    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    
    addi sp, sp, 8
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    lw t0, 0(s3)
    lw t1, 0(s6)
    # mul a0, t0, t1 # FIXME: Replace 'mul' with your own implementation

    multiplier_3:
    # Initialize result to 0
    li t5, 0            # t5 will hold the result (product)

        # Loop through each bit of b
    mul_loop_start_3:
        # Check if b is zero, if so, we're done
        beqz t1, mul_loop_end_3    # If b == 0, exit the loop

        # If the least significant bit of b is 1, add a to the result
        andi t6, t1, 1       # t6 = b & 1 (check the least significant bit of b)
        beqz t6, mul_skip_addition_3    # If the bit is 0, skip addition

        add t5, t5, t0       # result += a (add a to the result)

    mul_skip_addition_3:
        # Shift a left by 1 (multiply a by 2)
        slli t0, t0, 1       # a = a * 2 (left shift by 1)

        # Shift b right by 1 (divide b by 2)
        srli t1, t1, 1       # b = b / 2 (right shift by 1, arithmetic shift)

        # Repeat the loop
        j mul_loop_start_3

    mul_loop_end_3:
        # Return the result in a0
        mv a0, t5            # Copy result to t4 for return

    slli a0, a0, 2
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0 # move o to s10
    
    mv a6, a0 # o
    
    mv a0, s1 # move m1 array to first arg
    lw a1, 0(s5) # move m1 rows to second arg
    lw a2, 0(s6) # move m1 cols to third arg
    
    mv a3, s9 # move h array to fourth arg
    lw a4, 0(s3) # move h rows to fifth arg
    lw a5, 0(s8) # move h cols to sixth arg
    
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a0, 16(a1) # load filename string into first arg
    mv a1, s10 # load array into second arg
    lw a2, 0(s5) # load number of rows into fourth arg
    lw a3, 0(s8) # load number of cols into third arg
    
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10 # load o array into first arg
    lw t0, 0(s3)
    lw t1, 0(s6)
    mul a1, t0, t1 # load length of array into second arg
    # FIXME: Replace 'mul' with your own implementation
    
    multiplier_4:
    # Initialize result to 0
    li t5, 0            # t5 will hold the result (product)

        # Loop through each bit of b
    mul_loop_start_4:
        # Check if b is zero, if so, we're done
        beqz t1, mul_loop_end_4    # If b == 0, exit the loop

        # If the least significant bit of b is 1, add a to the result
        andi t6, t1, 1       # t6 = b & 1 (check the least significant bit of b)
        beqz t6, mul_skip_addition_4    # If the bit is 0, skip addition

        add t5, t5, t0       # result += a (add a to the result)

    mul_skip_addition_4:
        # Shift a left by 1 (multiply a by 2)
        slli t0, t0, 1       # a = a * 2 (left shift by 1)

        # Shift b right by 1 (divide b by 2)
        srli t1, t1, 1       # b = b / 2 (right shift by 1, arithmetic shift)

        # Repeat the loop
        j mul_loop_start_4

    mul_loop_end_4:
        # Return the result in a0
        mv a1, t5            # Copy result to t4 for return

    jal argmax
    
    mv t0, a0 # move return value of argmax into t0
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    
    addi sp, sp 12
    
    mv a0, t0

    # If enabled, print argmax(o) and newline
    bne a2, x0, epilouge
    
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal print_int
    li a0, '\n'
    jal print_char
    
    lw a0, 0(sp)
    addi sp, sp, 4
    
    # Epilouge
epilouge:
    addi sp, sp, -4
    sw a0, 0(sp)
    
    mv a0, s0
    jal free
    
    mv a0, s1
    jal free
    
    mv a0, s2
    jal free
    
    mv a0, s3
    jal free
    
    mv a0, s4
    jal free
    
    mv a0, s5
    jal free
    
    mv a0, s6
    jal free
    
    mv a0, s7
    jal free
    
    mv a0, s8
    jal free
    
    mv a0, s9
    jal free
    
    mv a0, s10
    jal free
    
    lw a0, 0(sp)
    addi sp, sp, 4

    lw ra, 0(sp)
    
    lw s0, 4(sp) # m0 matrix
    lw s1, 8(sp) # m1 matrix
    lw s2, 12(sp) # input matrix
    
    lw s3, 16(sp) 
    lw s4, 20(sp)
    
    lw s5, 24(sp)
    lw s6, 28(sp)
    
    lw s7, 32(sp)
    lw s8, 36(sp)
    
    lw s9, 40(sp) # h
    lw s10, 44(sp) # o
    
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit

```

## Result
```
test_abs_minus_one (__main__.TestAbs) ... ok
test_abs_one (__main__.TestAbs) ... ok
test_abs_zero (__main__.TestAbs) ... ok
test_argmax_invalid_n (__main__.TestArgmax) ... ok
test_argmax_length_1 (__main__.TestArgmax) ... ok
test_argmax_standard (__main__.TestArgmax) ... ok
test_chain_1 (__main__.TestChain) ... ok
test_classify_1_silent (__main__.TestClassify) ... ok
test_classify_2_print (__main__.TestClassify) ... ok
test_classify_3_print (__main__.TestClassify) ... ok
test_classify_fail_malloc (__main__.TestClassify) ... ok
test_classify_not_enough_args (__main__.TestClassify) ... ok
test_dot_length_1 (__main__.TestDot) ... ok
test_dot_length_error (__main__.TestDot) ... ok
test_dot_length_error2 (__main__.TestDot) ... ok
test_dot_standard (__main__.TestDot) ... ok
test_dot_stride (__main__.TestDot) ... ok
test_dot_stride_error1 (__main__.TestDot) ... ok
test_dot_stride_error2 (__main__.TestDot) ... ok
test_matmul_incorrect_check (__main__.TestMatmul) ... ok
test_matmul_length_1 (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul) ... ok
test_matmul_square (__main__.TestMatmul) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul) ... ok
test_read_1 (__main__.TestReadMatrix) ... ok
test_read_2 (__main__.TestReadMatrix) ... ok
test_read_3 (__main__.TestReadMatrix) ... ok
test_read_fail_fclose (__main__.TestReadMatrix) ... ok
test_read_fail_fopen (__main__.TestReadMatrix) ... ok
test_read_fail_fread (__main__.TestReadMatrix) ... ok
test_read_fail_malloc (__main__.TestReadMatrix) ... ok
test_relu_invalid_n (__main__.TestRelu) ... ok
test_relu_length_1 (__main__.TestRelu) ... ok
test_relu_standard (__main__.TestRelu) ... ok
test_write_1 (__main__.TestWriteMatrix) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix) ... ok

----------------------------------------------------------------------
Ran 46 tests in 32.899s

OK
```
