#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>


// copy file1 to file2

int main( int argc, char* argv[])
{
	int fd_file1;
	int fd_file2;

	if ( (fd_file1 = open(argv[1],O_RDONLY)) == -1){
		write(2,"File failed to open in read mode\n", 34);
		exit(-1);
	}

	if ( (fd_file2 = open(argv[2], O_CREAT|O_WRONLY, S_IRUSR)) == -1 ){
		write(2,"File failed to open in write mode \n", 36);
		close(fd_file1);
		exit(-1);
	}

	char c;
	while (read(fd_file1, &c, 1)){
		write(fd_file2,&c,1);
	}

	close(fd_file1);
	close(fd_file2);
	exit(0);

}
