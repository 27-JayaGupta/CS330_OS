In this assignment, you will implement condition variable and semaphore in xv6 and test the
implementation using a few user programs.

-------------------------
BEFORE YOU START
-------------------------

Study the implementation of ```spinlock``` and ```sleeplock``` in xv6. The relevant codes are in
```assignment3/xv6-riscv/kernel/spinlock.{h,c}``` and ```assignment3/xv6-riscv/kernel/sleeplock.{h,c}```.
Pay attention to the ```acquire```, ```release```, ```acquiresleep```, and ```releasesleep``` functions. While the
spinlock implements a busy-wait loop in acquire, the sleeplock puts the waiting processes
to sleep in acquiresleep function. Note how a process is put to sleep using the sleep function
and woken up later using the wakeup function. You will be using the same mechanism in the
condition variable and semaphore implementation. In all your implementations, you should use
sleeplock only.

---------------------------------
CONDITION VARIABLE IMPLEMENTATION
---------------------------------

Define the condition variable of type cond_t in a new file named ```assignment3/xv6-riscv/kernel/condvar.h```.
Think about what this type should be. In another new file ```assignment3/xv6-riscv/kernel/condvar.c```
implement the following three functions.

```c
void cond_wait (cond_t *cv, struct sleeplock *lock)
void cond_signal (cond_t *cv)
void cond_broadcast (cond_t *cv)
```

Since the sleep(...) function takes one ```void*``` argument and a ```spinlock*``` argument, you will have to
implement a new sleep function (you may name it condsleep) which takes a ```cond_t*``` and a ```sleeplock*```
argument. This function will be needed to implement cond_wait. The condsleep function should be
implemented in ```assignment3/xv6-riscv/kernel/proc.c```. 

Note that the wakeup function wakes up all processes that are waiting on a channel (a channel is
essentially a pointer). To wake up just one process (needed to implement cond_signal), you will
have to implement a new function ```wakeupone```(...) in ```assignment3/xv6-riscv/kernel/proc.c```. This function
will be almost identical to the wakeup function except that it will return as soon as it encounters
one process waiting on the channel. Include ```condvar.o``` in the OBJS list of ```assignment3/xv6-riscv/Makefile```.
Also, include all new function prototypes in ```assignment3/xv6-riscv/kernel/defs.h``` for smooth
compilation. These include cond_wait, cond_signal, cond_broadcast, condsleep, and wakeupone.

------------------------------------------
TESTING CONDITION VARIABLE IMPLEMENTATION
------------------------------------------

I have included three user programs in assignment3/xv6-riscv/user/ that make use of condition variables.
These are ```barriertest.c, barriergrouptest.c, condprodconstest.c```. The first one tests several rounds of
barrier. The second one divides all processes into two groups (works for even number of processes only)
and each group invokes several rounds of barrier. The third program implements multiple producers and
multiple consumers on a bounded buffer. Go through these programs and understand what they do and how
to run them. To get these programs to compile, you will need to implement a few new systems calls,
which I discuss below. Your implementation must not require any change in the user programs.

1. You will implement the barrier as a group of three system calls described below. You will implement
an array of barriers inside xv6. Fix the size of the array to ten. Declare this array at an appropriate
place inside the ```assignment3/xv6-riscv/kernel/``` directory. You may put this declaration in a new file as well.

    * ```barrier_alloc```: The barrier_alloc system call will find a free barrier from the barrier array and return
its id to the user program.

    * ```barrier```: This system call implements the barrier using condition variables. It takes three arguments:
        * barrier instance number
        *  barrier array id
        * number of processes.

        The implementation of this system
        call should be such that when a process enters the barrier it prints out a line like the following.

        ```c
        pid: Entered barrier#k for barrier array id n
        ```

        Replace pid, k, n with actual values. Also, after exiting the barrier, a process prints out a line like
        the following.

        ```c
        pid: Finished barrier#k for barrier array id n
        ```

        You should acquire an appropriate sleeplock for printing these without jumbling up the output.

    * ```barrier_free```: This system call frees the barrier corresponding to the passed barrier array id.

Here is a sample output of barriertest.

```c
$ barriertest 4 2
7: got barrier array id 0

8: Entered barrier#0 for barrier array id 0
7: Entered barrier#0 for barrier array id 0
9: Entered barrier#0 for barrier array id 0
10: Entered barrier#0 for barrier array id 0
10: Finished barrier#0 for barrier array id 0
10: Entered barrier#1 for barrier array id 0
7: Finished barrier#0 for barrier array id 0
7: Entered barrier#1 for barrier array id 0
8: Finished barrier#0 for barrier array id 0
9: Finished barrier#0 for barrier array id 0
8: Entered barrier#1 for barrier array id 0
9: Entered barrier#1 for barrier array id 0
9: Finished barrier#1 for barrier array id 0
7: Finished barrier#1 for barrier array id 0
8: Finished barrier#1 for barrier array id 0
10: Finished barrier#1 for barrier array id 0
$
```

Here is a sample output of barriergrouptest.

```c
$ barriergrouptest 4 2
11: got barrier array ids 0, 1

12: Entered barrier#0 for barrier array id 0
11: Entered barrier#0 for barrier array id 1
13: Entered barrier#0 for barrier array id 1
14: Entered barrier#0 for barrier array id 0
13: Finished barrier#0 for barrier array id 1
13: Entered barrier#1 for barrier array id 1
14: Finished barrier#0 for barrier array id 0
11: Finished barrier#0 for barrier array id 1
14: Entered barrier#1 for barrier array id 0
11: Entered barrier#1 for barrier array id 1
11: Finished barrier#1 for barrier array id 1
12: Finished barrier#0 for barrier array id 0
13: Finished barrier#1 for barrier array id 1
12: Entered barrier#1 for barrier array id 0
12: Finished barrier#1 for barrier array id 0
14: Finished barrier#1 for barrier array id 0
$
```

2. You will implement the multiple producers and multiple consumers on a bounded buffer using three
system calls described below. You will implement the bounded buffer and its code as discussed in the class where
each element of the buffer has a condition variable and other necessary fields (please refer to
```multi_prod_multi_cons.c``` in course homepage). Fix the size of the buffer to twenty. Declare the buffer at
an appropriate place in the ```assignment3/xv6-riscv/kernel/``` directory. You may put this declaration in a
new file as well.

    A. ```buffer_cond_init```: This system call initializes all sleeplocks and any other variable involved in the
    bounded buffer implementation.

    B. ```cond_produce```: This system call implements the producer function. It takes the produced value as argument.

    C. ```cond_consume```: This system call implements the consumer function. This system call should be implemented in
    such a way that the consumed item is printed out. Make sure to acquire a sleeplock before printing. The consumed
    item is also returned to the user program although it is not used.

Here is a sample output of condprodconstest.

```c
$ condprodconstest 20 3 2
Start time: 1345

0 1 2 3 4 5 6 7 8 10 9 11 12 20 40 21 41 22 42 23 43 24 44 25 45 26 46 27 47 28 14 13 15 16 29 30 31 32 33 34 35 36 37 38 39 48 49 50 51 52 53 54 17 55 18 56 19 57 58 59

End time: 1348
$
```

------------------------
SEMAPHORE IMPLEMENTATION
------------------------

You will implement the semaphore using condition variables and sleeplocks. This implementation is
available in the lecture slides. Define the semaphore structure in a new file named
```assignment3/xv6-riscv/kernel/semaphore.h```. In another new file ```assignment3/xv6-riscv/kernel/semaphore.c```
implement the following three functions.

```c
void sem_init (struct semaphore *s, int x)
void sem_wait (struct semaphore *s)
void sem_post (struct semaphore *s)
```

--------------------------------
TESTING SEMAPHORE IMPLEMENTATION
--------------------------------

I have included a user program named semprodconstest in ```assignment3/xv6-riscv/user/``` that implements
the multiple producer multiple consumer bounded buffer using semaphores. To get this program
to compile, you will need to implement a few new systems calls, which I discuss below. Your implementation
should not require any change in the user program. You will implement the bounded buffer and its code as
discussed in lecture slide#63. You will need to use a buffer that is separate from the buffer used
in the condition variable-based implementation of bounded buffer. Fix the size of the buffer to twenty.
Declare the buffer at an appropriate place in the ```assignment3/xv6-riscv/kernel/``` directory. You may put
this declaration in a new file as well.

1. ```buffer_sem_init```: This system call initializes all semaphores and any other variable involved in the
bounded buffer implementation.

2. ```sem_produce```: This system call implements the producer function. It takes the produced value as argument.

3. ```sem_consume```: This system call implements the consumer function. This system call should be implemented in
such a way that the consumed item is printed out. Make sure to acquire a sleeplock before printing. The consumed
item is also returned to the user program although it is not used.

Here is a sample output of semprodconstest.

```c
$ semprodconstest 20 3 2
Start time: 8105

0 20 40 21 41 22 42 23 43 24 44 25 45 46 47 48 50 49 51 52 53 54 55 56 57 58 59 1 2 26 3 4 5 6 7 8 9 10 11 12 13 27 28 14 29 15 30 31 32 33 34 35 36 16 17 18 19 37 38 39

End time: 8109
$
```

-----------
SUBMISSION
-----------

Before you submit, execute "make clean" without double quotes from directory assignment3/xv6-riscv.
Send one submission email per group to cs330autumn2022@gmail.com. The submission email's
subject should be "Assignment#3 of Group XX" without double quotes where XX should be replaced
by your group number. Attach the following to the email.

1. Create a zip ball of your user/ and kernel/ directories as follows from the xv6-riscv directory (replace
XX by your group number).

    ```
    zip -r GroupXX.zip user/ kernel/
    ```

    Attach GroupXX.zip to the email.

2. Prepare a PDF report describing briefly the implementation of condition variable, semaphore, and the nine new
system calls. Discuss your observation regarding the time taken to execute condprodconstest and semprodconstest
for the same inputs (time taken is end time minus start time; both these times are printed from the user program).
Discuss for a few input cases. Which of the two implementations (condition variable-based vs. semaphore-based) do
you observe to be faster? Explain your observation. Attach the report with the submission email. The only acceptable
format for the report is PDF.