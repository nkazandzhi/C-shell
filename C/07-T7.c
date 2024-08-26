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

	printf("command %s successfull, pid: %d, exit code: %d\n", argv[1], pid, WEXITSTATUS(pid));

	///////////// cmd 1
	
	int pid_cmd2 = fork();
	if ( pid_cmd2 < 0 ){
		err(1,"Fork failed\n");
	}

	if (pid_cmd2 == 0)
	{
		if((execlp(argv[2],argv[2],NULL)) == -1){
			err(2, "Exec failed");
		}
	}

	int status2;
	pid_cmd2=wait(&status2);

	if(pid_cmd2 < 0)
	{
		err(2,"Could not wait for child!\n");
	}
	if(!WIFEXITED(status2)){
		errx(3,"Child was killed\n");
	}else if(WEXITSTATUS(status2) != 0)
	{
		errx(4,"Child doesnt have exit status 0\n");
	}

	printf("command %s successfull, pid: %d, exit code: %d\n", argv[2], pid_cmd2, WEXITSTATUS(pid_cmd2));

	////////////////////////////// cmd 2

	int pid_cmd3 = fork();
	if ( pid_cmd3 < 0 ){
		err(1,"Fork failed\n");
	}

	if (pid_cmd3 == 0)
	{
		if((execlp(argv[3],argv[3],NULL)) == -1){
			err(2, "Exec failed");
		}
	}

	int status3;
	pid_cmd3=wait(&status3);

	if(pid_cmd3 < 0)
	{
		err(2,"Could not wait for child!\n");
	}
	if(!WIFEXITED(status3)){
		errx(3,"Child was killed\n");
	}else if(WEXITSTATUS(status3) != 0)
	{
		errx(4,"Child doesnt have exit status 0\n");
	}

	printf("command %s successfull, pid: %d, exit code: %d\n", argv[3], pid_cmd3, WEXITSTATUS(pid_cmd3));

	exit(0);
}
