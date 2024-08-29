 #include <stdint.h>
       #include <stdio.h>
       #include <stdlib.h>
       #include <sys/wait.h>
       #include <unistd.h>
#include <err.h>

int main(int argc, char* argv[])
{
	if ( argc != 2)
	{
		errx(1,"Error: wrong number of arguments!");
	}

	int pf[2];

	if(pipe(pf) == -1 )
	{
		err(10, "pipe failed");
	}


	int child_pid = fork();

	if ( child_pid == -1 )
	{
		err(2, "Error: fork failed");
	}

	if (child_pid == 0 )
	{
		//child process
		close(pf[0]);

		if (dup2(pf[1],1) == -1)
		{
			close(pf[1]);
			err(6, "dup2 failed");
		}

		if(execlp("cat", "cat", argv[1], NULL) == -1)
		{
			err(7, "Execlp failed");
		}

	}

	close(pf[1]);

	int status;
	wait(&status);

	if (status == -1 )
	{
		close(pf[0]);
		err(3, "Error: could not wait for child");
	}

	if(! WIFEXITED(status))
    {
    	close(pf[0]);
    	err(4, "Child did not terminate normally");
	}

    if( WEXITSTATUS(status) != 0 )
	{
		close(pf[0]);
		err(5, "Child did not terminate with code 0");
	}

	if (dup2(pf[0],0) == -1)
	{
		err(8, "dup2 failed");
	}

	if(execlp("sort","sort",NULL) == -1)
	{
		err(9, "execl failed");
	}

	exit(0);

}
