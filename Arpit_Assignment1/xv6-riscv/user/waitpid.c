#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){

    int x = 0,p;
    printf("Parent with pid : <%d> created\n",getpid());
    for(int i=0;i<5;i++){

        x = fork();
        if(x==0){
            // printf("Child with pid : <%d> created\n",getpid());
            if(i%2==0)
            sleep(2);
            exit(0);
        }
        if(i%2==0){
            int child = waitpid(x,&p);
            if(child<0){
                printf("Child with pid <%d> does not exist\n",x);
            }else{
                printf("Child with pid %d exited\n",x);
            }
        }

    }
    if(waitpid(x+1,&p)<0)
    printf("Child with pid %d does not exist\n",x+1);
    exit(0);

}