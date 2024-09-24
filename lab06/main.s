.globl _start  

_start:
    jal read

    li s1, 0
    li s2, 4
outer_for:
    bge s1, s2, end_outer_for

    # get chars from input
    la a0, input_address
    li t1, 5
    mul t1, s1, t1
    add a0, a0, t1

    lbu t1, 0(a0)
    lbu t2, 1(a0)
    lbu t3, 2(a0)
    lbu t4, 3(a0)

    # converts to integer  
    addi t1, t1, -48
    addi t2, t2, -48
    addi t3, t3, -48
    addi t4, t4, -48

    # converts to decimal
    li a0, 1000
    mul t1, t1, a0
    li a0, 100
    mul t2, t2, a0
    li a0, 10
    mul t3, t3, a0

    # a4 stores the value
    li a4, 0
    add a4, a4, t1
    add a4, a4, t2
    add a4, a4, t3
    add a4, a4, t4

    # calc square root
    li a7, 2          # a7 will store 2 to help in the calc
    divu a3, a4, a7   # (k) a3 <=  y / 2
    li a1, 0          # iterator
    li a2, 10         # limit of the for loop
for:
    bge a1, a2, endfor
    
    divu t1, a4, a3 # t1 <= y / k
    add  t1, a3, t1 # t1 <= k + (y / k)
    divu a3, t1, a7 # k  <= [k + (y / k)] / 2

    addi a1, a1, 1
    j for
endfor:
    li a6, -1 # a6 <= -1
    # converts to char
    li a0, 1000
    divu t1, a3, a0
    mul a1, t1, a6
    mul a1, a1, a0
    add a3, a3, a1
    addi t1, t1, 48

    li a0, 100
    divu t2, a3, a0
    mul a1, t2, a6
    mul a1, a1, a0
    add a3, a3, a1
    addi t2, t2, 48

    li a0, 10
    divu t3, a3, a0
    mul a1, t3, a6
    mul a1, a1, a0
    add a3, a3, a1
    addi t3, t3, 48
    
    addi a3, a3, 48

    # value is now saved like: 
    # (t1)(t2)(t3)(a3)

    # store in result
    la a0, result
    li t4, 5
    mul t4, s1, t4
    add a0, a0, t4

    li t4, 32

    sb t1, 0(a0)
    sb t2, 1(a0)
    sb t3, 2(a0)
    sb a3, 3(a0)
    sb t4, 4(a0)

    addi s1, s1, 1
    j outer_for
end_outer_for:
    
    la a0, result
    li t4, 10
    sb t4, 19(a0)

    jal write
    
    li a0, 0
    li a7, 93 # exit
    ecall

read:
    li a0, 0            # file descriptor = 0 (stdin)
    la a1, input_address # buffer
    li a2, 20           # size - Reads 20 bytes.
    li a7, 63           # syscall read (63)
    ecall
    ret

write:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, result       # buffer
    li a2, 20           # size - Writes 20 bytes.
    li a7, 64           # syscall write (64)
    ecall
    ret


.bss

input_address: .skip 0x20  # buffer

result: .skip 0x20