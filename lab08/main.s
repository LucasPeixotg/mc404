.data
input_file: .asciz "image.pgm"

.bss
input_buffer: .skip 262159

.text
.globl _start
.align 2
_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

.align 2
main:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal open
    jal read
    la s1, input_buffer

    # read header
    addi s1, s1, 3  # P5\n

    li t1, '0'
    li t2, 10
    li s2, 0
1:
    mv a0, s2
    lbu t3, 0(s1)
    addi s1, s1, 1
    bgt t1, t3, 1f
    addi t3, t3, -48
    mul s2, s2, t2
    add s2, s2, t3
    j 1b
1:

    li t1, '0'
    li t2, 10
    li s3, 0
1:
    mv a0, s2
    lbu t3, 0(s1)
    addi s1, s1, 1
    bgt t1, t3, 1f
    addi t3, t3, -48
    mul s3, s3, t2
    add s3, s3, t3
    j 1b
1:

    addi s1, s1, 4 #255\n
    # s2 contains width
    # s3 contains height

    mv a0, s2
    mv a1, s3
    jal setCanvasSize

test:

    li a1, 0
1:
    bge a1, s3, 1f
    li a0, 0
2:
    bge a0, s2, 2f

    lbu a2, 0(s1)
    addi s1, s1, 1
    jal set_pixel

    addi a0, a0, 1
    j 2b
2:
    addi a1, a1, 1
    j 1b
1:


    lw ra, 0(sp)
    addi sp, sp, 4
    ret



# set_pixel
# params:
#   a0 -> x coordinate
#   a1 -> y coordinate
#   a2 -> color value
.align 2
set_pixel:
    mv a3, a2
    
    slli a2, a2, 8
    or a2, a2, a3
    
    slli a2, a2, 8
    or a2, a2, a3

    slli a2, a2, 8
    ori a2, a2, 0x000000FF

    li a7, 2200 # syscall setPixel (2200)
    ecall
    ret


# open
# returns:
#   a0 -> file descriptor for file
.align 2
open:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open 
    ecall
    ret

# read
# params:
#   a0 -> file descriptor
.align 2
read:
    la a1, input_buffer
    li a2, 262159    # size (1 byte)
    li a7, 63   # syscall read (63)
    ecall
    ret

# setCanvasSize
# params: 
#   a0 -> canvas width
#   a1 -> canvas height
setCanvasSize:
    li a7, 2201
    ecall
    ret