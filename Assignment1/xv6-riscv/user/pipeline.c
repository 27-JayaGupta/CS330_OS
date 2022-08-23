#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void 
pipeline(int n, int x) {
    if (n) {
        int pipefd[2];

        if(pipe(pipefd) < 0){
            fprintf(1, "Failed in formation of pipes.\n");
            exit(1);
        }

        int pid = fork();

        if(pid < 0) {
            fprintf(1, "Failed in formation of child process.\n");
            exit(1);
        }

        if(pid == 0) {
            int a;

            if(read(pipefd[0], &a, sizeof(a)) < 0){
                fprintf(1, "Error pipe: cannot read\n");
                exit(1);
            }

            close(pipefd[0]);
            close(pipefd[1]);
            --n;
            pipeline(n, a);
            exit(0);
        }
        else {
            int parent_pid = getpid();
            // fprintf(1, "In parent, pid: %d\n", parent_pid);
            x += parent_pid;
            fprintf(1, "%d: %d\n", parent_pid, x);
            if(write(pipefd[1],&x, sizeof(x)) < 0){\
                fprintf(1, "Error pipe: cannot write\n");
                exit(1);
            }
            
            close(pipefd[0]);
            close(pipefd[1]);
            wait(0);
        }
    }    
}

int
main(int argc, char* argv[])
{   
    if (argc != 3) {
        fprintf(1, "usage: pipeline n x\n");
        exit(1);
    }
   
    if(atoi(argv[1]) <= 0) {
        fprintf(1, "n must be positive.\n");
        exit(1);
    }

    pipeline(atoi(argv[1]), atoi(argv[2]));

    exit(0);
}