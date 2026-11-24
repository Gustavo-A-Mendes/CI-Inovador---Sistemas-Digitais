#include <stdio.h>

int main(void) {
    __int8_t a, b;

    a = 127;
    b = a + 1;

    printf("%d", b);

    return 0;
}