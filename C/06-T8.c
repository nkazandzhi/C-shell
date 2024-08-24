#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <err.h>
#include <errno.h>
#include <unistd.h>

int main(int argc, char* argv[])
{

	if ( argc != 1 )
	{
		errx(2, "Can't have args");
	}

	char* etc = "/etc/passwd";
	char* new_file = "./passwd.txt";

	int fd_etc;
	int fd_new;

	if ((fd_etc = open(etc,O_RDONLY)) == -1 ){
		err(1, "Can't open ./etc/passwd");
	}
	
	if ((fd_new = open(new_file, O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1 )
	{
		close(fd_etc);
		err(2, "Can't create ./passwd.txt");
	}

	// both files are open successully

	char c;

	while (read(fd_etc,&c,1) > 0)
	{
		if ( c == ':')
		{
			c = '?';
		}
		if (write(fd_new,&c,1) == -1)
		{
			close(fd_etc);
			close(fd_new);
			err(3, "Can't write to file");
		}
	}

	
	close(fd_etc);
	close(fd_new);
	exit(0);
}
