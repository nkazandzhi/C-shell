#include <stdio.h>    // for printf
#include <stdlib.h>   // for exit
#include <unistd.h>   // for fork
#include <err.h>      // for err, errx
#include <sys/wait.h> 

int main(int argc, char* argv[])
{
	int pid = fork();
	if ( pid < 0 ){
		err(1,"Fork failed\n");
	}

	if (pid == 0)
	{
		printf("Hey im child!\n");
		exit (0);
	}

	int status;
	pid=wait(&status);

	if(pid < 0)
	{
		err(2,"Could not wait for child!\n");
	}
	if(!WIFEXITED(status)){
		errx(3,"Child was killed\n");
	}else if(WEXITSTATUS(status) != 0)
	{
		errx(4,"Child doesnt have exit status 0\n");
	}

	printf("Everything is as expected\n");
	exit (0);
}

////////////////////////////////////////////////////////////


#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <err.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void)
{
	int n = 1000000;
	int status;

	pid_t a = fork();
	if (a == -1) {
		err(1, "BOO");
	}
	if (a > 0) {
		wait(&status);
		for (int i = 0; i < n; i++) {
			printf("father\n");
		}
	} else {
		for (int i = 0; i < n; i++) {
			printf("son\n");
		}
	}

	exit(0);
}
