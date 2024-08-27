#include <unistd.h>
#include <err.h>
#include <errno.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

struct pair
{
	uint32_t x;
	uint32_t y;
};

int fds[3]; // ne go polzvam tova

void close_all()
{
	for(int i =0; i<3; i++)
	{
		if(fds[i] >= 0)
		{
			close(fds[i]);
		}
	}
}

int main(int argc, char* argv[])
{
	if (argc != 4)
	{
		errx(1,"ERROR: Arg count");
	}

	int fd1,fd2;

	if ((fd1 = open(argv[1],O_RDONLY)) == -1){
		err(2, "Cant open f1");
	}

	if ((fd2 = open(argv[2], O_RDONLY)) == -1){
		close(fd1);
		err(2, "Cant open f2");
	}
	
	struct stat s;

	if(fstat(fd1,&s) == -1)
	{
		close(fd1);
		close(fd2);
		err(7,"Couldf not fstat");
	}

	if (s.st_size % 8 != 0)
	{
		close(fd1);
		close(fd2);
		errx(3,"File1 must be devisible by 8");
	}

	struct pair p;

	int bytes_count =0 ;

	int fd3;

	if ((fd3=open(argv[3],O_WRONLY|O_CREAT, 0644)) == -1 )
	{
		close(fd1);
		close(fd2);
		err(5,"Cant open file3");
	}

	while((bytes_count = read(fd1,&p,sizeof(p)))>0)
	{
		if(lseek(fd2, p.x * 4, SEEK_SET) == -1)
		{
			close(fd1);
			close(fd2);
			close(fd3);
			err(6,"Error: lseek");
		}

		uint32_t buf;

		for(uint32_t i =0; i<p.y; i++)
		{
			if(read(fd2,&buf,sizeof(buf)) == -1)
			{

				close(fd1);
				close(fd2);
				close(fd3);
				err(7,"Error: reading");
			}
			if(write(fd3,&buf,sizeof(buf)) == -1)
			{

				close(fd1);
				close(fd2);
				close(fd3);
				err(7,"Error: writing");
			}
		}
	}

	if(bytes_count == -1)
	{

		close(fd1);
		close(fd2);
		close(fd3);
		err(8,"Error: Reading");
	}

	close(fd1);
	close(fd2);
	close(fd3);
	exit(0);

}
