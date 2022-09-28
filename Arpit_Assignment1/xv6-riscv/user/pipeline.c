#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

int pipefd[2];
int n,x;

void fun(int m){

    if(m==0)
    return;
    int x1;
    int c;
    if(m==n){
        x1 = x+getpid();
    }
    else{
        if(read(pipefd[0],&c,4)<0){
            fprintf(2,"Error in reading from pipeline. Aborting...\n");
            exit(1);
        }
        int pid = getpid();
        x1 = c+pid;
    }
    if(write(pipefd[1],&x1,4)<0){
        fprintf(2,"Error in writing to pipeline. Aborting...\n");
        exit(1);
    }
    printf("%d: %d\n",getpid(),x1);
    int f = fork();
    if(f<0){
	    fprintf(2,"Error in fork. Aborting...\n");
	    exit(1);
    }
    if(f==0){
        // sleep(1);
        fun(m-1);
    }else{
        close(pipefd[0]);
        close(pipefd[1]);
        // printf("%d\n",m);
        wait(NULL);
    }
    return;

}

int main(int argc, char * argv[]){

    if(argc!=3){
        fprintf(2,"syntax: pipeline <int> <int>\n");
        exit(1);
    }
    n = atoi(argv[1]);
    x = atoi(argv[2]);
    if(n<=0){
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
        exit(1);
    }
    if(pipe(pipefd)<0){
        fprintf(2,"Error in creating pipe. Aboritng...\n");
        exit(1);
    }
    fun(n);
    exit(0);

}
