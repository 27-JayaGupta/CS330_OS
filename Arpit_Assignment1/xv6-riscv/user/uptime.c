#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void uptime_wrapper(){

    printf("Seconds since system woke up %d\n",uptime()/10);

}

int main(){

    uptime_wrapper();
    exit(0);

}