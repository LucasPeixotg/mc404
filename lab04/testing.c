#include <stdio.h>

/*
converts char to integer
*/
int char2int(char a) {
    int v = (int) a - 48;
    return  v > 9? v - 39 : v;
}

/*
converts char to integer
*/
char int2char(int a) {
    char v = (char) a + 48;
    return  v > '9'? v + 39 : v;
}

#define BUFFER_SIZE 32 


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

void write(char* string, int size) {
    for(int i = 0; i < size; i++)
        printf("%c", string[i]);
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


    //write(STDOUT_FD, decimal, size+negative+1);
    write(decimal, size+negative+1);
}


int main(void) {
    
    char hex[32] = "0x80000000";

    int number = hex_array2decimal_int(hex, 10);

    printf("%d\n", number);

    int test = -2147483648;
    write_decimal(number);
}