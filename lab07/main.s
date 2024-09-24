.bss
xy_buffer: .skip 0x12
times_buffer: .skip 0x20

.text
.globl _start
.align 2
_start:
    jal main

    li a0, 0
    li a7, 93 # exit
    ecall

# main function
.align 2
main:
    addi sp, sp, -4
    sw ra, 0(sp)    # push ra to stack
    ##

    # read first input
    la a1, xy_buffer
    li a2, 12
    jal read

    # load first number
    la t1, xy_buffer
    lbu a1, 0(t1)
    lbu a2, 1(t1)
    lbu a3, 2(t1)
    lbu a4, 3(t1)
    lbu a5, 4(t1)
    # convert first number to decimal
    jal signed_to_int
    mv s3, a0

    # load second number
    la t1, xy_buffer
    lbu a1, 6(t1)
    lbu a2, 7(t1)
    lbu a3, 8(t1)
    lbu a4, 9(t1)
    # convert second number to decimal
    jal signed_to_int
    mv s4, a0

    # read second input
    la a1, times_buffer
    li a2, 20
    jal read

    # load first number of second input (Tr)
    la t1, times_buffer
    lbu a1, 0(t1)
    lbu a2, 1(t1)
    lbu a3, 2(t1)
    lbu a4, 3(t1)
    
    # convert it to decimal
    jal to_int
    mv s5, a0
    
    # load second number of second input (Ta)
    la t1, times_buffer
    lbu a1, 5(t1)
    lbu a2, 6(t1)
    lbu a3, 7(t1)
    lbu a4, 8(t1)
    # convert it to decimal
    jal to_int
    mv s6, a0

    # load third number of second input (Tb)
    la t1, times_buffer
    lbu a1, 10(t1)
    lbu a2, 11(t1)
    lbu a3, 12(t1)
    lbu a4, 13(t1)
    # convert it to decimal
    jal to_int
    mv s7, a0

    # load fourth number of second input (Tc)
    la t1, times_buffer
    lbu a1, 15(t1)
    lbu a2, 16(t1)
    lbu a3, 17(t1)
    lbu a4, 18(t1)
    # convert it to decimal
    jal to_int
    mv s8, a0

    # current saved registers
    # s3 = Xc
    # s4 = Yb
    # s5 = Tr
    # s6 = Ta
    # s7 = Tb
    # s8 = Tc

    # calculate Da, Db
    sub t1, s5, s6 # delta ta
    sub t2, s5, s7 # delta tb
    li t3, 3
    li t4, 10
    mul s6, t1, t3
    div s6, s6, t4
    mul s6, s6, s6

    mul s7, t2, t3
    div s7, s7, t4
    mul s7, s7, s7
    # current saved registers changed to
    # s6 = Da²
    # s7 = Db²

    # calculate y:
    mul t0, s4, s4 # t0 <= Yb²
    slli t1, s4, 1 # t1 <= 2 Yb

    add s2, s6, t0 # s2 <= Da² + Yb²
    sub s2, s2, s7 # s2 <= Da² + Yb² - Db²
    div s2, s2, t1 # s2 <= (Da² + Yb² - Db²) / 2 Yb

    # calculate x:
    mul t1, s2, s2
    sub a1, s6, t1 # a1 <= Da² - y²
    jal sqrt
    mv s1, a0
    bgt s3, x0, 1f
    li t1, -1
    mul s1, s1, t1
1:

    # convert x to char
    mv a1, s1
    jal to_char

    # store x in the buffer
    la t0, xy_buffer
    sb a0, 0(t0)
    sb a1, 1(t0)
    sb a2, 2(t0)
    sb a3, 3(t0)
    sb a4, 4(t0)
    li t1, ' '
    sb t1, 5(t0)

    # convert y to char
    mv a1, s2
    jal to_char

    # store y in the buffer
    la t0, xy_buffer
    sb a0, 6(t0)
    sb a1, 7(t0)
    sb a2, 8(t0)
    sb a3, 9(t0)
    sb a4, 10(t0)
    li t1, '\n'
    sb t1, 11(t0)

    # write the result
    la a1, xy_buffer
    li a2, 12
    jal write
    
    # return
    lw ra, 0(sp)    # pop ra from stack
    addi sp, sp, 4
    ret

# sqrt
# params:
#   a1 -> value
# returns:
#   a0 -> sqrt(value)
sqrt:
    slli a0, a1, 1 # a0 <= y / 2

    li t1, 21
    li t0, 0
1:
    addi t0, t0, 1
    bgt t0, t1, 1f

    div t2, a1, a0 # t2 <= y / k
    add a0, a0, t2 # a0 <= k + (y / k)
    srai a0, a0, 1 # a0 <= [ k + (y / k) ] / 2

    j 1b
1:
    ret

# TODO: change to ABI
# to_char
# params:
#   a1 -> signed value
# returns:
#   a0 -> sign 
#   a1 -> thousands char
#   a2 -> hundreds  char
#   a3 -> decimals  char
#   a4 -> units     char
to_char:
    # load sign and convert to positive
    li a0, '+'
    bgt a1, x0, 1f
    li a0, '-'
    li t1, -1
    mul a1, a1, t1
1:
    # calculate the value of each position
    mv t0, a1
    li t1, 1000
    div a1, t0, t1
    mul t1, t1, a1
    sub t0, t0, t1
    
    li t1, 100
    div a2, t0, t1
    mul t1, t1, a2
    sub t0, t0, t1
    
    li t1, 10
    div a3, t0, t1
    mul t1, t1, a3
    sub t0, t0, t1

    mv a4, t0

    # convert to char
    addi a1, a1, '0'
    addi a2, a2, '0'
    addi a3, a3, '0'
    addi a4, a4, '0'
    ret

# to_int
# params:
#   a1 -> first  char
#   a2 -> second char
#   a3 -> third  char
#   a4 -> fourth char
# returns:
#   a0 -> converted number
.align 2
to_int:
    # converts to integer
    addi t0, a1, -48
    addi t1, a2, -48
    addi t2, a3, -48
    addi t3, a4, -48

    # converts to decimal
    li t4, 1000
    mul t0, t0, t4
    li t4, 100
    mul t1, t1, t4
    li t4, 10
    mul t2, t2, t4

    li a0, 0
    add a0, a0, t0
    add a0, a0, t1
    add a0, a0, t2
    add a0, a0, t3

    ret

# signed_to_int
# params:
#   a1 -> sign
#   a2 -> first  char
#   a3 -> second char
#   a4 -> third  char
#   a5 -> fourth char
# returns:
#   a0 -> converted number
.align 2
signed_to_int:
    # converts to integer
    addi t1, a2, -48
    addi t2, a3, -48
    addi t3, a4, -48
    addi t4, a5, -48

    # converts to decimal
    li t5, 1000
    mul t1, t1, t5
    li t5, 100
    mul t2, t2, t5
    li t5, 10
    mul t3, t3, t5

    li a0, 0
    add a0, a0, t1
    add a0, a0, t2
    add a0, a0, t3
    add a0, a0, t4

    li t1, '-'
    bne a1, t1, 1f
    li t6, -1
    mul a0, a0, t6
1:
    ret

# read
# params:
#   a1 -> input buffer address
#   a2 -> size in bytes
.align 2
read:
    li a0, 0    # file descriptor = 0 (stdin)
    li a7, 63   # syscall read (63)
    ecall
    ret

# write
# params:
#   a1 -> buffer address
#   a2 -> size in bytes
.align 2
write:
    li a0, 1    # file descriptor = 1 (stdout)
    li a7, 64   # syscall write (64)
    ecall
    ret