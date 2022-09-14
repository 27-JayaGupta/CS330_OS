#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char* argv[]) 
{   
    fprintf(1,"Before yield\n");
    yield();
    fprintf(1,"[%d] After yield.\n", getpid());
    exit(0); 
}