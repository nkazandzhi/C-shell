//err, open, write
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <sys/wait.h>
 #include <unistd.h>
 #include <fcntl.h>
 #include <err.h>
 #include <string.h>


int main(int argc, char* argv[])
{
	if ( argc != 2 )
	{
		errx(1, "Wrong number of arguments!");
	}

	const char * filename = argv[1];
	int fd_file;

	if (( fd_file = open(filename, O_WRONLY)) == -1)
	{
		err(2, "Failed to open the file!");
	}

	const char* fo = "fo";
	//const char * bar = "bar\n";
	//const char * o = "o\n";

	if (( write(fd_file, fo, strlen(fo))) != strlen(fo))
	{	
		close(fd_file);
		err(3, "Failed to write 'fo' into the file");
	}

	int child_pid = fork(); 
	if ( child_pid == -1)
	{
		close(fd_file);
		err(4,"Fork failed");
	}

	if (child_pid == 0)
	{
		//child process activities

		const char * bar = "bar\n";

		if (( write(fd_file, bar, strlen(bar))) != strlen(bar))
		{	
			close(fd_file);
			err(8, "Failed to write 'bar' into the file");
		}
		close(fd_file);
		exit(0);
	}

	int status;
	child_pid=wait(&status);

	if (child_pid == -1)
	{ 	err(6,"Could not wait for child");
	}

	if (!WIFEXITED(status)) {
		err(5,"Child didnt termiante normally");
	}

	if (WEXITSTATUS(status) != 0)
	{
		err(7, "Child didnt terminate with 0");
	}

	//parent process
	
	const char * o = "o\n";

	if (( write(fd_file, o, strlen(o))) != strlen(o))
	{	
		close(fd_file);
		err(9, "Failed to write 'o' into the file");
	}

	close(fd_file);
	exit(0);
}
