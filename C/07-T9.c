#include <stdio.h>   // for printf
#include <stdlib.h>  // for exit
#include <unistd.h>  // for fork
#include <err.h>  
#include <errno.h>
#include <string.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{


	const char* file = argv[1];
	int fd;

	if (( fd = open(file, O_WRONLY|O_CREAT|O_TRUNC, 0644) ) == -1)
	{
		err(5,"Open failed");
	}


	pid_t pid = fork();

	if(pid < 0 ){
		err(1,"cant fork");
	}

	if(pid > 0)
	{
		
	const char *foo = "foo";
	const ssize_t len = strlen(foo);		

	if(write(fd, foo, len) != len){
		const int old_errno = errno;
		close(fd);
		errno = old_errno;
		err(4, "error while writing to file %s", file);
		}

	exit(0);
		
	}
	
	const char *bar = "bar";
	const ssize_t len = strlen(bar);		

	if(write(fd, bar, len) != len){
		const int old_errno = errno;
		close(fd);
		errno = old_errno;
		err(4, "error while writing to file %s", file);
		}

	close(fd);
	exit(0);


}
