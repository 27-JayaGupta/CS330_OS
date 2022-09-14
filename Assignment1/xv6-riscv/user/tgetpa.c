#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int global_var;
int
main(int argc, char*argv[])
{      
    int x;
    int y;
    char c,d;
    printf("Virtual address of x: %p, physical address of x: %l\n",&x, getpa(&x));
    printf("Virtual address of y: %p, physical address of y: %l\n",&y, getpa(&y));
    printf("Virtual address of c: %p, physical address of c: %l\n",&c, getpa(&c));
    printf("Virtual address of d: %p, physical address of d: %l\n",&d, getpa(&d));
    printf("Virtual address of global: %p, physical address of global: %l\n",&global_var, getpa(&global_var));
    exit(0);
}