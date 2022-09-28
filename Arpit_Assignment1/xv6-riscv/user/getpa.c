#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){

    int x,y;
    printf("Physical address is : %p, %p\n",getpa(&x),getpa(&y));
    exit(0);

}