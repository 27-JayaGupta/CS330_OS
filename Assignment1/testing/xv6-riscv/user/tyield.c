#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char* argv[]) 
{   
    fprintf(1,"Before yield\n");
    if(fork() == 0) {
        
        for(int i = 0; i < 10; i++){
            printf("Child: %d\n", i);
            yield();
            yield();
        }
    } else {
        
        for(int i = 0; i < 10; i++)
            printf("Parent: %d\n", i);
    }
    exit(0); 
}