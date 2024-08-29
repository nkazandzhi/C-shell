 //  find ~ -printf "%T@ %p\n" | sort | head -n 1 | cut -d ' ' -f2 
//                             a      b           c
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
	if ( argc != 2 )
	{
		errx(1, "Wrong number of arguments!");
	}

	struct stat st;
	if (stat(argv[1],&st) == -1)
	{
		err(2, "stat failed");
	}

	//if(st.st_mode != S_IFDIR)
	//{
	//	errx(3, "arg must be a dir");
	//}

	int a[2];
	if (pipe(a) == -1)
	{
		err(4,"pipe failed");
	}

	pid_t child_pid = fork();
	if ( child_pid == -1) 
	{
		err(5,"fork failed");
	}
	
	if(child_pid == 0)
	{
		close(a[0]);
		if ( dup2(a[1],1) == -1)
		{
			err(6, "dup failed");
		}

		if ( execlp("find","find", argv[1], "-printf", "%T@ %p \n", NULL) == -1)
		{
			err(7,"exec failed");
		}

//  find ~ -printf "%T@ %p\n" | sort | head -n 1 | cut -d ' ' -f2 
//                            a      b           c
	}
	close(a[1]);
//a[0] otvorena
	wait(NULL);
	int b[2];
	if(pipe(b) == -1)
	{
		err(4,"pipe failed");
	}
	child_pid = fork();
	if(child_pid == -1 )
	{
		err(5,"fork failed");
	}
	if(child_pid == 0)
	{	
		close(b[0]);
		if(dup2(a[0],0) == -1)
		{
			err(6,"dup failed");
		}
		if(dup2(b[1], 1) == -1)
		{
			err(6,"dup failed");
		}
		if (execlp("sort", "sort", NULL) == -1)
		{
			err(7,"exec failed");
		}
	}
	close(b[1]);
//b[0] otvorena
	wait(NULL);
	
	int c[2];

//  find ~ -printf "%T@ %p\n" | sort | head -n 1 | cut -d ' ' -f2 
//                            a      b           c
	if(pipe(c) == -1)
	{
		err(4,"pipe failed");
	}
	child_pid = fork();
	if(child_pid == -1 )
	{
		err(5,"fork failed");
	}
	if(child_pid == 0)
	{	
		close(c[0]);
		if(dup2(b[0],0) == -1)
		{
			err(6,"dup failed");
		}
		if(dup2(c[1], 1) == -1)
		{
			err(6,"dup failed");
		}
		if (execlp("head", "head","-n","1", NULL) == -1)
		{
			err(7,"exec failed");
		}
	}
	close(c[1]);
//otvorena(c[0]);
	wait(NULL);
	close(b[0]);

		if(dup2(c[0],0)==-1)
		{
			err(6,"dup failed");
		}

		if(execlp("cut", "cut", "-d", " ", "-f2", NULL) == -1)
		{
			err(7,"execlp failed");
		}


}
