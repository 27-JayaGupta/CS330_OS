#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){

    printf("Return value of yield is %d\n",yield());
    exit(0);

}