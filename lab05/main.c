#define STDIN_FD  0
#define STDOUT_FD 1

int read(int __fd, const void *__buf, int __n){
    int ret_val;
    __asm__ __volatile__(
        "mv a0, %1           # file descriptor\n"
        "mv a1, %2           # buffer \n"
        "mv a2, %3           # size \n"
        "li a7, 63           # syscall write code (63) \n"
        "ecall               # invoke syscall \n"
        "mv %0, a0           # move return value to ret_val\n"
        : "=r"(ret_val)  // Output list
        : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
    );
    return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
    __asm__ __volatile__(
        "mv a0, %0           # file descriptor\n"
        "mv a1, %1           # buffer \n"
        "mv a2, %2           # size \n"
        "li a7, 64           # syscall write (64) \n"
        "ecall"
        :   // Output list
        :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
        : "a0", "a1", "a2", "a7"
    );
}

void exit(int code)
{
    __asm__ __volatile__(
        "mv a0, %0           # return code\n"
        "li a7, 93           # syscall exit (64) \n"
        "ecall"
        :   // Output list
        :"r"(code)    // Input list
        : "a0", "a7"
    );
}

void _start()
{
    int ret_code = main();
    exit(ret_code);
}

/*
converts char to integer
*/
int char2int(char a) {
    int v = (int) a - '0';
    return  v > 9? v - 39 : v;
}

/*
converts integer to char
*/
char int2char(int a) {
    return  a > 9? a - 10 + 'A' : a + '0';
}

void hex_code(unsigned val){
    char hex[11];
    unsigned aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = val % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        val = val / 16;
    }
    write(1, hex, 11);
}

unsigned decimal_to_binary(char* start) {
    unsigned abs = char2int(start[4]) + char2int(start[3]) * 10 + char2int(start[2]) * 100 + char2int(start[1]) * 1000;

    if(start[0] == '-') return ~abs + 1;
    return abs;
}

unsigned pack(unsigned n1, unsigned n2, unsigned n3, unsigned n4, unsigned n5) {
    unsigned value = 0;
    
    value = n5 & 127;
    value = value << 4;

    value = value | (n4 & 15);
    value = value << 9;

    value = value | (n3 & 511);
    value = value << 7;

    value = value | (n2 & 127);
    value = value << 5;

    value = value | (n1 & 31);

    return value;
}

int main(void) {
    char buffer[30];
    read(STDIN_FD, buffer, 30);

    unsigned n1 = decimal_to_binary(buffer);
    unsigned n2 = decimal_to_binary(buffer + 6);
    unsigned n3 = decimal_to_binary(buffer + 12);
    unsigned n4 = decimal_to_binary(buffer + 18);
    unsigned n5 = decimal_to_binary(buffer + 24);

    unsigned result = pack(n1, n2, n3, n4, n5);
    hex_code(result);
}