#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{
	int fd_file; 
	if ((fd_file = open(argv[1], O_RDONLY)) == -1 ){
		write(1, "Cant open", 9);
		exit (-1);
	}

	int line = 0;
	char c;

	//while (read(fd_file, &c, sizeof(c)) == sizeof(c)) { 
	while (read(fd_file, &c,1))
	{
		if (c == '\n')
		{
			line = line+1;
		}
		write(1,&c,1);

		if(line == 10){
			break;
		}
	}
  close(fd_file);
  exit(0);
}
