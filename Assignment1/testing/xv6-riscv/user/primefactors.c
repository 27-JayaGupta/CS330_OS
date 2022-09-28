#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};

void 
primefactors(int n, int prime_idx) {
    if(prime_idx >= (sizeof(primes)/sizeof(primes[0]))) {
        return;
    }

    if (n > 1) {
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
            primefactors(a, ++prime_idx);
            exit(0);
        }
        else {
            int parent_pid = getpid();
            int flag = 0;
            while(n % primes[prime_idx] == 0) {
                flag = 1;
                n = n/primes[prime_idx];
                fprintf(1, "%d, ", primes[prime_idx]);
            }

            if(flag) fprintf(1,"[%d]\n", parent_pid);
            
            if(write(pipefd[1],&n, sizeof(n)) < 0){\
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
main(int argc, char*argv[])
{
    if (argc != 2) {
        fprintf(1, "usage: primefactors c\n");
        exit(1);
    }
   
    if((atoi(argv[1]) < 2) || (atoi(argv[1])>100)) {
        fprintf(1, "c must be in range[0,100]. Integer only.\n");
        exit(1);
    }

    primefactors(atoi(argv[1]), 0);

    exit(0);
}