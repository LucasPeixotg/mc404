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

#define STDIN_FD  0
#define STDOUT_FD 1
#define BUFFER_SIZE 32

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
    char v = a + '0';
    return  v > '9'? v + 39 : v;
}


/*
converts an array of chars, representing a decimal value to an integer number. 
The array must contain only numbers (can't end with '\n')
*/
int decimal_string2decimal_int(char number[BUFFER_SIZE], int number_size) {
    int result = 0;

    for(int i = number[0]=='-'? 1 : 0; i < number_size; i++) {
        result = result*10 + char2int(number[i]);
    }

    if(number[0] == '-') result *= -1;

    return result;
}

/*
converts an array of chars, representing a hexadecimal value to an integer number (decimal). 
The array must contain only numbers (can't end with '\n')
*/
int hex_array2decimal_int(char number[BUFFER_SIZE], int number_size) {
    int result = 0;
    int current_pow = 1;
    
    // while i >= 2 because the number starts with 0x
    for(int i = number_size-1; i >= 2; i--) {
        result += current_pow * char2int(number[i]);
        current_pow *= 16;
    }

    return result;
}

/*
converts a decimal number to a binary number and writes the result to stdout
*/
void decimal2binary(int decimal_int, char* binary, int* binary_size) {
    /* BINARY NUMBER */
    char inverted_binary[BUFFER_SIZE];
    int value = decimal_int < 0? -decimal_int: decimal_int;
    
    int bsize = 0;
    while(value != 0) {
        inverted_binary[bsize++] = value % 2;
        value /= 2;
    }
    
    binary[0] = '0';
    binary[1] = 'b';
    if(decimal_int < 0) {
        // two's complement
        // set initial two's complement binary
        for(int i = 2; i < BUFFER_SIZE+2; i++) binary[i] = '1';

        char carry = 1;
        for(int i = 0; i < bsize; i++) {
            // complement then sum (xor)
            binary[BUFFER_SIZE-i+1] = int2char((!inverted_binary[i] && !carry) || (carry && inverted_binary[i]));
            carry = !inverted_binary[i] && carry;
        }

        // 
        if(carry) binary[BUFFER_SIZE+1-bsize] = int2char(carry);
        binary[BUFFER_SIZE+2] = '\n';

        *binary_size =  BUFFER_SIZE+3;

    } else {
        // positive value

        for(int i = 0; i < bsize; i++) {
            binary[bsize - i + 1] = int2char(inverted_binary[i]);
        }

        // bsize is incresed by 3 because of the initial '0b' and the '\n'
        bsize += 3;
        binary[bsize-1] = '\n';

        // write the binary number to the standard output
        *binary_size = bsize;
    }
}

/*
Converts a binary string into a decimal int number
(assumes the binary is a 32 bit number, including 0b and '\n')
0b00000000000000000000000000000000
*/
unsigned binary2decimal(char* binary) {
    unsigned decimal = 0;
    int pow = 1;

    for(int i = 33; i >=  2; i--) {
        decimal += pow * char2int(binary[i]);
        pow *= 2;
    }

    return decimal;
}

void invert_endianess(char* inverted_endianess, char* binary, int binary_size) {
    inverted_endianess[0] = '0';
    inverted_endianess[1] = 'b';
    
    char complete_bin[BUFFER_SIZE];
    for(int i = BUFFER_SIZE-1, j = 0; i >= 0; i--, j++) {
        if(j < binary_size - 3) {
            complete_bin[i] = binary[binary_size - 2 - j];
        } else {
            complete_bin[i] = '0';
        }
    }
    
    // invert first byte
    inverted_endianess[2] = complete_bin[24];
    inverted_endianess[3] = complete_bin[25];
    inverted_endianess[4] = complete_bin[26];
    inverted_endianess[5] = complete_bin[27];
    inverted_endianess[6] = complete_bin[28];
    inverted_endianess[7] = complete_bin[29];
    inverted_endianess[8] = complete_bin[30];
    inverted_endianess[9] = complete_bin[31];
    
    // invert second byte
    inverted_endianess[10] = complete_bin[16];
    inverted_endianess[11] = complete_bin[17];
    inverted_endianess[12] = complete_bin[18];
    inverted_endianess[13] = complete_bin[19];
    inverted_endianess[14] = complete_bin[20];
    inverted_endianess[15] = complete_bin[21];
    inverted_endianess[16] = complete_bin[22];
    inverted_endianess[17] = complete_bin[23];

    // invert third byte
    inverted_endianess[18] = complete_bin[8];
    inverted_endianess[19] = complete_bin[9];
    inverted_endianess[20] = complete_bin[10];
    inverted_endianess[21] = complete_bin[11];
    inverted_endianess[22] = complete_bin[12];
    inverted_endianess[23] = complete_bin[13];
    inverted_endianess[24] = complete_bin[14];
    inverted_endianess[25] = complete_bin[15];

    // invert fourth byte
    inverted_endianess[26] = complete_bin[0];
    inverted_endianess[27] = complete_bin[1];
    inverted_endianess[28] = complete_bin[2];
    inverted_endianess[29] = complete_bin[3];
    inverted_endianess[30] = complete_bin[4];
    inverted_endianess[31] = complete_bin[5];
    inverted_endianess[32] = complete_bin[6];
    inverted_endianess[33] = complete_bin[7];

    inverted_endianess[BUFFER_SIZE + 2] = '\n';
}

/*
converts a decimal number to an octal number and writes the result to stdout
*/
void write_decimal(int number) {
    int negative = number < 0;

    int size = 0;
    char inverted_decimal[BUFFER_SIZE+10];
    
    int correct = negative? -1 : 1;
    while(number != 0) {
        inverted_decimal[size++] = number % 10 * correct;
        number /= 10;
    }

    // decimal size:  '-' (if negative) + number size + '\n'
    char decimal[size + negative + 1];
    for(int i = 0; i < size; i++)
        decimal[size + negative - i - 1] = int2char(inverted_decimal[i]);
    
    if(negative) decimal[0] = '-';
    decimal[size + negative] = '\n';

    write(STDOUT_FD, decimal, size+negative+1);
}

/*
converts a decimal number to an octal number and writes the result to stdout
*/
void write_decimal_unsigned(unsigned number) {
    int size = 0;
    char inverted_decimal[BUFFER_SIZE+10];
    
    while(number != 0) {
        inverted_decimal[size++] = number % 10;
        number /= 10;
    }

    char decimal[size + 1];
    for(int i = 0; i < size; i++)
        decimal[size - i - 1] = int2char(inverted_decimal[i]);
    
    decimal[size] = '\n';

    write(STDOUT_FD, decimal, size+1);
}

/*
*/
void write_hex(unsigned number) {
    char hex[BUFFER_SIZE+3];

    hex[0] = '0';
    hex[1] = 'x';

    int total_size = 0, temp = number;
    while(temp != 0) temp /= 16;

    for(int i = 2; i < total_size+2; i++) {
        hex[i] = int2char(number & 15);
        number = number >> 15;
    }

    hex[total_size+2] = '\n';

    write(STDOUT_FD, hex, total_size+3);
}

int main()
{
    char str[BUFFER_SIZE];

    // Read up to 20 bytes from the standard input into the str buffer
    int n = read(STDIN_FD, str, BUFFER_SIZE);
    
    // number will be the decimal representation
    int input_is_decimal = 1;
    int decimal_int;

    if(n >= 2 && str[1] == 'x') {
        // hexadecimal input
        input_is_decimal = 0;
        decimal_int = hex_array2decimal_int(str, n-1);
    } else {
        // decimal input
        decimal_int = decimal_string2decimal_int(str, n-1);
    }

    /* BINARY NUMBER */
    int binary_size;
    char binary[BUFFER_SIZE + 3];
    decimal2binary(decimal_int, binary, &binary_size);

    write(STDOUT_FD, binary, binary_size);

    /* DECIMAL NUMBER */
    if(input_is_decimal) write(STDOUT_FD, str, n);
    else write_decimal(decimal_int);

    // revert endianess
    char inverted_endianess[BUFFER_SIZE + 3];
    invert_endianess(inverted_endianess, binary, binary_size);

    unsigned reverted_decimal = binary2decimal(inverted_endianess);
    write_decimal_unsigned(reverted_decimal);

    if(input_is_decimal) {
        char hex[BUFFER_SIZE];

        //unsigned value;
        //if(decimal_int < 0) value = ~(decimal_int + 1);
        //else value = decimal_int;
        //write_decimal_unsigned(value);

        write_hex(decimal_int);
    } else write(STDOUT_FD, str, BUFFER_SIZE);

    return 0;
}