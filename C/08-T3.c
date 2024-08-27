#include <stdlib.h>
#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		errx(1,"Wrong number of arguments!");
	}

	int pf[2];

	if(pipe(pf) == -1)
	{
		err(2, "Failed to create a pipe");
	}

	const pid_t child_pid = fork();

	if(child_pid == -1)
	{
		err(3,"Could not fork!");
	}

	if(child_pid == 0)
	{
		close(pf[1]);
		close(0);
		dup(pf[0]);
		sleep(5);
		if(execlp("wc","wc","-c", NULL) == -1)
		{
			err(4,"Could not exec.");
		}
	}

	close(pf[0]);
	write(pf[1],argv[1],strlen(argv[1]));
	close(pf[1]);

	wait(NULL);

	exit(0);
}
