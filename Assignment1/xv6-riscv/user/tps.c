#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char*argv[])
{   
    int pid = fork();
    if(pid == 0){
        sleep(5);
    }
    else {
        sleep(10);
        ps();
    }
    exit(0);
}