#include <unistd.h>
#include <stdlib.h>
#include <err.h>

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		errx(1,"Wrong number of arguments!");
	}

	int result;
	if ((result = execlp("ls","ls",argv[1],NULL))== -1)
	{
		err(2,"LS failed");
	}
	exit(0);
}
