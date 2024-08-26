#include <unistd.h>
#include <stdlib.h>
#include <err.h>

int main(int argc, char* argv[])
{
	if (argc != 1)
	{
		errx(1,"Wrong number of arguments!");
	}

	int result;
	if ((result = execl("/bin/sleep","sleep","10",NULL))== -1)
	{
		err(2,"LS failed");
	}
	exit(0);
}
