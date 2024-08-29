#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>

int main(int argc,char * argv[])
{
	const int BUFF_SIZE = 4096;
	char buff[BUFF_SIZE];

	ssize_t bytes_read;

	const char *prompt = "Enter command: ";

	if (write(1,prompt,strlen(prompt)) != strlen(prompt))
	{
		err(1, "write failed");
	}

	while((bytes_read = read(1,buff, sizeof(buff)))>0)
	{
		buff[bytes_read -1] = '\0';
		pid_t child = fork();

		if(child == -1)
		{
			err(3, "fork failed");
		}
		
		if(strcmp(buff, "exit") == 0)
		{
			exit(0);
		}

		if (child == 0)
		{
			char command[BUFF_SIZE];
            strcpy(command, "/bin/");
            strcat(command, buff);
            if (execl(command, buff, (char *)NULL) == -1) {
                err(6, "Could not exec %s", buff);
            }
		
		}

		int status;
   		if (wait(&status) == -1) {
        	err(4, "Could not wait for child process to finish");    }

    	if (!WIFEXITED(status)) {
        	 errx(5, "Child process did not terminate normally");    }

    	if (WEXITSTATUS(status) != 0) {
        	 errx(6, "Child process finished with exit code not 0"); }

    	if (write(1, prompt, strlen(prompt)) != (int)strlen(prompt)) {
        	err(1, "Failed writing"); }
	}

	if(bytes_read == -1)
	{
		err(2,"Failed reading");
	}



}
