#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <err.h>

//cut -d ':' -f 7  /etc/passwd | sort | uniq -c | sort
//                             a      b         c

int main(int argc, char* argv[])
{
	if (argc != 1 )
	{
		errx(1,"wrong number of arguments");
	}

	int a[2];
	if (pipe(a) == -1)
	{
		err(2,"Pipe failed");
	}

	pid_t pid = fork();
	if ( pid == -1)
	{
		err(3, "fork failed");
	}
	if(pid == 0)
	{
		close(a[0]);
		if(dup2(a[1],1) == -1)
		{
			close(a[1]);
			err(4,"dup2 failed");
		}
		if(execlp("cut", "cut", "-d", ":", "-f", "7", "/etc/passwd", NULL) == -1)
		{
			close(a[1]);
			err(5,"execlp cut failed");
		}

	}
	close(a[1]);
	
	int b[2];
	if(pipe(b) == -1)
	{
		err(6,"pipe failed");
	}

	pid = fork();

	if ( pid == -1 )
	{	
		close(b[1]);
		close(b[0]);
		err(7,"fork failed");
	}

	if(pid == 0)
	{
		//read from a
		//write to b
		close(b[0]);
		if(dup2(a[0],0) == -1){
			err(8,"dup2 fail");	
		}
		if(dup2(b[1],1) == -1)
		{	err(8, "dup2 fail");
		}
		if ( execlp("sort", "sort", NULL) == -1)
		{
			err(5,"exelp sort failed");
		}

	}

	close(b[1]);
	

	//cut -d ':' -f 7  /etc/passwd | sort | uniq -c | sort
	//                             a      b         c

	int c[2];
	if (pipe(c) == -1)
	{
		err(6,"pipe failed");
	}

	pid = fork();
	if (pid == -1)
	{
		err(6,"fork failed");
	}

	if(pid == 0)
	{
		//read from b[0]
		//write c[1]
		close(c[0]);
		if(dup2(b[0],0) == -1)
		{
			err(8,"dup2 failed");
		}
		if(dup2(c[1],1) == -1)
		{
			err(8,"dup2 failed");
		}
		if ( execlp("uniq", "uniq", "-c", NULL) == -1)
		{
			err(5,"execlp failed");
		}
	}

	close(c[1]);

	close(a[0]);
	close(b[0]);

	while (wait(NULL) > 0);

	if(dup2(c[0], 0) == -1)
	{
		err(11,"error dup");
	}

	if(execlp("sort","sort", "-n", NULL) == -1)
	{
		err(11, "exec");
	}

	return 0;
}
