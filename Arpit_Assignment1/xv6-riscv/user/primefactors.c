#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stddef.h>

int pipefd[2];

void primefactors(int * primes, int i, int n){

    
    if(n==1)
    return;
    int f = fork();
    if(f<0){
        fprintf(2,"Error in fork. Aborting...\n");
        exit(1);
    }
    if(f==0){
        int a;
        if(read(pipefd[0],&a,sizeof(a))<0){
            fprintf(2,"Error in read. Aborting...\n");
            exit(1);
        }
        primefactors(primes,i+1,a);
    }else{
        int cnt = 0;
        while(n%primes[i]==0){
            n/=primes[i];
            cnt++;
        }
        if(cnt>0){
            for(int j=0;j<cnt;j++)
            printf("%d, ",primes[i]);
            printf("[%d]\n",getpid());

        }
        if(write(pipefd[1],&n,sizeof(n))<0){
            fprintf(2,"Error in write. Aborting...\n");
            exit(1);
        }
        close(pipefd[0]);
        close(pipefd[1]);
        wait(NULL);
    }

}

int main(int argc, char *argv[]){

    int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};
    if(argc!=2){
        fprintf(2,"Syntax: primefactors <int>\n");
        exit(1);
    }
    int n = atoi(argv[1]);
    if(n<2||n>100){
        fprintf(2,"Enter n between 2 and 100\n");
        exit(1);
    }
    if(pipe(pipefd)<0){
        fprintf(2,"Error in creating pipe. Aborting...\n");
        exit(1);
    }
    primefactors(primes,0,n);
    exit(0);

}