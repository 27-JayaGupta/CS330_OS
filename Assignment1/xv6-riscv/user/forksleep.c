#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void 
forksleep(int m, int n){

    int pid = fork();

    if (pid<0) {
        fprintf(1, "Error in forking the process.\n");
        exit(1);
    }

    if(pid == 0) {
        if (n == 0) {
            sleep(m);
        }
        fprintf(1, "%d: Child.\n", getpid());
        exit(0);
    }
    else {
        if(n == 1) {
            sleep(m);
        }
        
        fprintf(1, "%d: Parent.\n", getpid());
        wait(0);
    }
    
    return;
}

int
main (int argc, char* argv[]) 
{   
    if (argc != 3) {
        fprintf(1, "usage: forksleep m n. m and n are integers.\n");
        exit(1);
    }

    if (argv[1][0] == "-") {
        fprintf(1, "m should be positive.\n");
        exit(1);
    }

    if (argv[2][0] == "-") {
        fprintf(1, "n can be 0 or 1. \n");
        exit(1);
    }

    int m,n;
    m = atoi(argv[1]);
    n = atoi(argv[2]);

    fprintf(1, "m: %d,n: %d \n", m,n);

    if (m == 0) {
        fprintf(1, "m should be positive.\n");
        exit(1);
    }

    if (n != 0 && n != 1) {
        fprintf(1, "n can be 0 or 1. \n");
        exit(1);
    }

    forksleep(m,n);
    exit(0);
}