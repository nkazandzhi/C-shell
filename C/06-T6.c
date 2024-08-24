#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <err.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
	for (int i = 1; i < argc; i++)
	{
		int fd;
		if (( fd = open(argv[i],O_RDONLY)) == -1)
		{
			err(1, "Cant open file");
		}
		char buffer[4096];

		ssize_t read_size;

		while ((read_size = read(fd,buffer,sizeof(buffer))) > 0)
		{
			if((write(1,buffer,read_size)) != read_size )
			{
				close(fd);
				err(2,"Can't cat the file");
			}
				
		}
		close(fd);
	}
	exit(0);
}
