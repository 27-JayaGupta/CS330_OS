## Implementation Details

#### Syscall: ps

(*Implemented in kernel/proc.c*)
\
`ps` syscall does not take any arguments and returns 0 on successful execution. To implement this syscall, iterate over the process table, acquire the process lock for the current chosen process to access critical fields in its Process Control Block struct. Skip the process if the process is in `UNUSED` state else get the rest of information and print it. It is required to acquire wait_lock before accessing the parent of process and process lock needs to released before acquiring wait_lock to maintain the order locks in which to acquire them.



#### Syscall: pinfo

(*Implemented in kernel/proc.c*)
\
`pinfo` returns the information for process in the struct for the given pid, both of which are passed as arguments. If pid is -1, the information for calling process in returned. The implementation of this syscall is similar to `ps`, except for the information storing part, where the process info is first stored in a kernel data structure (declared in *kernel/procstat.h*) and the copied into the user data structure(using the `copyout` function) whose address is passed as argument.