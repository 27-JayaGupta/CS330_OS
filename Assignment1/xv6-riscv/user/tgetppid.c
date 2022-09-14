#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int
main(int argc, char*argv[])
{
    int pid = fork();

    if(pid == 0){
        fprintf(1,"[%d] Child calling: Parent Pid is [%d]\n", getpid(), getppid());
    } else {
        wait(0);
        fprintf(1,"[%d] Parent calling: My Parent Pid is [%d]\n", getpid(), getppid());
    }
    exit(0);
}