#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdbool.h>

// count lines, chars, words in a file

int main(int argc, char* argv[])
{	
	if(argc != 2 )
	{
		write(2, "Wrong number of arguments!",27);
		exit(1);
	}

	int chars = 0;
	int words = 0;
	int lines = 0;

	int fd_file;
	char c;

	if (( fd_file = open(argv[1], O_RDONLY)) == -1 )
	{
		write(2, "Cant open", 9);
		exit(1);
	}

	//fd opened
	while (read(fd_file, &c, sizeof(c)) == sizeof(c)){

		chars = chars + 1;

		if ( c == ' ')
		{
			words = words + 1;
		}
		else if ( c == '\n' )
		{
			words = words + 1;
			lines = lines + 1;
		}
		else { }
	}

	printf("File has %d lines, %d words, %d chars.\n", lines, words, chars);	close(fd_file);

	exit(0);
}
