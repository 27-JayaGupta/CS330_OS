#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int main(int argc, char * argv[]){

    if(argc!=3){
        fprintf(2,"usage: forksleep <int> <int>\n");
        exit(1);
    }
    int m = atoi(argv[1]);
    int n = atoi(argv[2]);
    if(m<0){
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
        exit(1);
    }
    if(n!=0&&n!=1){
        fprintf(2,"Error: second argument can only be 0 or 1. Aborting...\n");
        exit(1);
    }
    int f = fork();
    if(f<0){
        fprintf(2,"Error in fork. Aborting...\n");
        exit(1);
    }else if(f==0){
        if(n==0){
            sleep(m);
            printf("%d: Child\n",getpid());
            exit(0);
        }else if(n==1){
            printf("%d: Child\n",getpid());
            exit(0);
        }
    }else{
        if(n==0){
            printf("%d: Parent\n",getpid());
            exit(0);
        }else if(n==1){
            sleep(m);
            printf("%d: Parent\n",getpid());
            exit(0);
        }
    }
    exit(0);

}