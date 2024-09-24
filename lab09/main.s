.bss
buffer: .skip 7

.text
.globl _start
.align 2
_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

# find: recursive function to find a value in a linked list
#   (it actually searches for the sum of the three values of the linked list)
# params:
#   a0: current index
#   a1: head address
#   a2: searched value
# returns:
#   a0: index of searched node or -1
.align 2
find:
    # base case (current addres is 0, so value is NOT FOUND)
    bne a1, x0, 1f
    li a0, -1
    ret
    1:
    
    # save ra
    addi sp, sp, -4
    sw ra, 0(sp)

    lw t1, 0(a1)
    lw t2, 4(a1)
    lw t3, 8(a1)
    lw t4, 12(a1)

    add t1, t1, t2
    add t1, t1, t3

    # check value
    beq t1, a2, 1f
        addi a0, a0, 1
        mv a1, t4
        jal find
    1:

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

.align 2
main:
    addi sp, sp, -4
    sw ra, 0(sp)

    # read input
    jal read

    # buffer address will always be saved on s5
    la s5, buffer

    # convert input to int
    # integer will be saved on s1
    li s1, 0
    
    mv a0, s5    # a0 <- current_address 

    lbu t1, 0(s5)       # t1 <- first char 
    li t2, 0x2d
    bne t1, t2, 1f    # branch if t1 != '-'
        addi a0, a0, 1
    1:

    # change input values to integer and sums up the total
    2:
    lbu t1, 0(a0)       # t1 <- input_buffer[i], because input_buffer[i] equals a0[0]
    li t5, 48
    bgt t5, t1, 2f      # branch if '0' > t1
    addi t1, t1, -48    # convert to int
    li t2, 10           # 
    mul s1, s1, t2      # s1 *= 10
    add s1, s1, t1      # s1 += t1
    addi a0, a0, 1      # a0 += 1
    j 2b
    2:

    # check if its negative
    lbu t1, 0(s5)   # t2 <- first char 
    li t2, 0x2d
    bne t1, t2, 1f # branch if t2 != '-'
        li t1, -1
        mul s1, s1, t1
    1:

    # call recursive function
    mv a0, x0
    la a1, head_node
    mv a2, s1
    jal find

after_found:

    # check if a0 == -1 (no node with value)
    li t1, -1
    bne a0, t1, 1f
    li t1, '-'
    li t2, '1'
    li t3, '\n'
    sb t1, 0(s5)
    sb t2, 1(s5)
    sb t3, 2(s5)
    li a0, 3

    j 2f
    1:

    
    # a0 is not negative, convert to char and stores on buffer
    # loop to push chars to stack
    li a1, 0
    li a2, 10
    do:
        div t1, a0, a2
        mul t1, t1, a2

        sub t3, a0, t1
        div a0, a0, a2

        addi t3, t3, 48

        addi sp, sp, -4
        sw t3, 0(sp)

        addi a1, a1, 1
    bgt a0, x0, do
    mv a2, a1
    addi s4, a2, 1

    # loop to get chars from stack
    mv a3, s5
    4:
    bge x0, a1, 4f

    lw t1, 0(sp)
    addi sp, sp, 4

    sb t1, 0(a3)

    addi a3, a3, 1
    addi a1, a1, -1
    j 4b
    4:
    
    li t1, '\n'
    sb t1, 0(a3)
    mv a0, s4
    2:
    jal write

    # print result

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# saves 7 bytes from STDIN to the buffer
.align 2
read:
    la a1, buffer
    li a2, 7    # size (7 bytes)
    li a7, 63   # syscall read
    ecall
    ret

# write
# write bytes from input buffer to STDOUT
# params:
#   a0 -> size in bytes
.align 2
write:
    mv a2, a0
    la a1, buffer
    li a0, 1    # file descriptor = 1 (stdout)
    li a7, 64   # syscall write (64)
    ecall
    ret