#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){

    printf("Parent pid is : %d\n",getppid());
    exit(0);

}