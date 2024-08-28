//мое решение, което не е съвсем вярно и използва fprintf, което не забранено ппц
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{

	if (strcmp("-n", argv[1])== 0)
	{
		//we should count lines
		uint8_t line = 1;

		for(int i = 2; i < argc;i++)
		{
			if(strcmp(argv[i],"-") == 0)
			{
				
				dprintf(1, "%d ", line);
				ssize_t readb;
				char c;
				while(readb = read(0, &c,sizeof(c)) >0)
				{
					
					if (write(1,&c,sizeof(c)) == -1)
					{
						err(1,"Error");
					}
					if (c == '\n')
					{
						line++;
						dprintf(1, "%d ", line);


					}

				}
			}
			else
			{

				dprintf(1, "%d ", line);
				ssize_t readb;
				char c;
				int fd = open(argv[i],O_RDONLY);
				if (fd == -1) {
					err(3, "Error: cant open");
				}
				while(readb = read(fd, &c,sizeof(c)) >0)
				{
					
					if (write(1,&c,sizeof(c)) == -1)
					{
						err(1,"Error");
					}
					if (c == '\n')
					{
						line++;
						dprintf(1, "%d ", line);


					}

				}
				close(fd);
			}
		}
	}
	else
	{
		//we dont count lines
		//just read row by row
		for(int i = 1; i < argc;i++)
		{
			if(strcmp(argv[i],"-") == 0)
			{
				
				ssize_t readb;
				char c;
				while(readb = read(0, &c,sizeof(c)) >0)
				{
					
					if (write(1,&c,sizeof(c)) == -1)
					{
						err(1,"Error");
					}
				
				}
			}
			else
			{

				
				ssize_t readb;
				char c;
				int fd = open(argv[i],O_RDONLY);
				if (fd == -1) {
					err(3, "Error: cant open");
				}
				while(readb = read(fd, &c,sizeof(c)) >0)
				{
					
					if (write(1,&c,sizeof(c)) == -1)
					{
						err(1,"Error");
					}
				
				}
				close(fd);
			}
		}
	}
	exit(0);
	
}

