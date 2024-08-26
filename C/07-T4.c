#include <stdio.h>   // for printf
#include <stdlib.h>  // for exit
#include <unistd.h>  // for fork
#include <err.h>  
int main(int argc, char* argv[])
{

	pid_t pid = fork();

	if(pid < 0 ){
		err(1,"cant fork");
	}

	if(pid > 0)
	{
		for (int i = 0; i < 50; i++) {
			printf("father\n");
			
		}
		
	}
	else
	{
		for (int i = 0; i <50; i++) {
			printf("son\n");
			
		}
		
	}

	exit (0);
}
