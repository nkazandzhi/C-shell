#include "stdio.h"
#include "string.h"
#include "fcntl.h"
#include "unistd.h"
#include "stdint.h"
#include "err.h"
#include <stdlib.h>

int main(int argc, char* argv[])
{
	if ( argc != 2)
	{
		errx(1, "Invalid number of arguments!");
	}

	char *file_name = argv[1];

	int fd; 

	if (( fd = open(file_name, O_RDWR)) < 0 )
	{
		err(2, "Can't open file!");
	}

	uint32_t bytes[256] = {0};

	uint8_t buf;
	int bytes_read = 0;

	while(( bytes_read = read(fd,&buf,sizeof(buf))) >0){

		bytes[buf] += 1;

	}

	if (bytes_read < 0)
	{
		close(fd);
		err(3,"Can't read from file");
	}

	if (lseek(fd,0,SEEK_SET) < 0)
	{
		close(fd);
		err(4, "Lseek failed");
	}

	for ( int i = 0; i< 256; i++)
	{
		uint8_t c = i;
		for(int j = 0; j<bytes[i]; j++)
		{
			if(write(fd,&c,sizeof(c))<0)
			{
				close(fd);
				err(5,"Can't write to file");
			}
		}
	}

	close(fd);

	exit(0);

}
