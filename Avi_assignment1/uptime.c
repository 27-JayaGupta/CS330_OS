#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
// #include<stdio.h>
int main(){
    int p=uptime();
    printf("Uptime is : %d\n",p);
    exit(0);
}   