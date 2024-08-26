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
		if((execlp(argv[1],argv[1],NULL)) == -1){
			err(2, "Exec failed");
		}
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

	printf("command %s successfull", argv[1]);
	exit (0);
}
