#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include <stddef.h>
#include <stdbool.h>
bool check(char num[])
{
	int i = 0;
	if (num[0] == '-')
		i = 1;
	for (; num[i] != '\0'; i++)
	{
		if ('0' <= num[i] && '9' >= num[i])
			;
		else
		{
			return false;
		}
	}
	return true;
}
int main(int argc, char **argv)
{
	if (argc != 3)
	{
		printf("There should be two arguments\n");
		exit(0);
	}

	if (!check(argv[2]) || !check(argv[1]))
	{
		printf("Arguments should be integer\n");
		exit(0);
	}
	int n = atoi(argv[1]);
	int x;
	if (argv[2][0] == '-')
	{
		x = -atoi(argv[2] + 1);
	}
	else
	{
		x = atoi(argv[2]);
	}

	if (n <= 0)
	{
		printf("First argument should be positive\n");
	}
	while (n--)
	{
		int arr[2];
		if (pipe(arr) < 0)
		{
			printf("error in pipe\n");
			exit(0);
		};
		int t = fork();
		if (t < 0)
		{
			printf("error in fork\n");
			exit(0);
		}
		// child
		if (t == 0)
		{
			read(arr[0], &x, sizeof(int));
			close(arr[0]);
			close(arr[1]);
		}
		else
		{ // parent
			int pid = getpid();
			x += pid;
			printf("%d: %d\n", pid, x);
			close(arr[0]);

			write(arr[1], &x, sizeof(int));
			close(arr[1]);
			wait(NULL);
			exit(0);
		}
	}

	exit(0);
}
