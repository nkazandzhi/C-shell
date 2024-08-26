#include <unistd.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
	if (argc != 1)
	{
		errx(1,"Wrong number of arguments!");
	}

	int result;
	if ((result = execl("/bin/date","date",NULL))== -1)
	{
		err(2,"Date failed");
	}
	exit(0);
}
