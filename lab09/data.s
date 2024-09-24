.globl head_node

.data
head_node: 
    .word 10
    .word -4
    .word -2
    .word node_1
.skip 10
node_1: 
    .word 56
    .word 78
    .word 25
    .word node_2
.skip 5
node_3:
    .word -100
    .word -43
    .word -201
    .word 0
node_2:
    .word -654
    .word 590
    .word 1277
    .word node_3