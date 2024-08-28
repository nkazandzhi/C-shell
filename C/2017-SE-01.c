//мое решение!
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include <err.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{
	if ( argc != 4)
	{
		errx(1, "Error: wrong number of arguments!");
	}

	//f1.bin and f2.bin are uint8_t
	//f1.bin is "original"
	//f2.bin is f1.bin but modified
	//patch.bin -> uint16_t offset
	//          -> uint8_t original
	//          -> uint8_t pos 
	//We have to create patch.bit

	int f1_fd, f2_fd;

	if (( f1_fd = open(argv[1], O_RDONLY) ) == -1 )
	{
		err(2, "Error: cant open f1");
	}

	if (( f2_fd = open(argv[2], O_RDONLY) ) == -1 )
	{
		close(f1_fd);
		err(2, "Error: cant open f2");
	}

	struct pos{
		uint16_t offset_;
		uint8_t original_;
		uint8_t replacement_;
	};

	int f3_fd;

	if (( f3_fd = open(argv[3], O_WRONLY|O_CREAT|O_TRUNC,0644)) == -1){
		close(f1_fd);
		close(f2_fd);
		err(3, "Error: Cant create f3");
	}

	struct stat f1_s;
	struct stat f2_s;

	if ( stat(argv[1],&f1_s) == -1 ) { err(4, "Error:Stat failed"); }

	if ( stat(argv[2],&f2_s) == -1 ) { err(4, "Error:Stat failed"); }

	if ( f1_s.st_size != f2_s.st_size )
	{
		errx(5, "Files are not consistent.");
	}

	uint8_t f1sym;
	uint8_t f2sym;

	ssize_t read_bytes_f1;
	ssize_t read_bytes_f2;

	while(( read(f1_fd, &f1sym, sizeof(f1sym))) >0 )
	{
		uint16_t off = lseek(f1_fd,0,SEEK_CUR);
		if ( off == -1)
		{
			err(5, "Error: lseek");
		}

		if((read_bytes_f2 = read(f2_fd, &f2sym, sizeof(f2sym))) > 0)
		{
			if ( f1sym != f2sym )
			{
				struct pos p;
				p.offset_ = off-1;
				p.original_ = f1sym;
				p.replacement_ = f2sym;

				if (write(f3_fd, &p, sizeof(p)) != sizeof(p))
				{
					err(6, "Error: writing p");
				}
			}
		}
	}

	if ( read_bytes_f1 == -1 || read_bytes_f2 == -1 )
	{
		close(f1_fd);
		close(f2_fd);
		close(f3_fd);
		err(7, "Error reading!");
	}

	close(f1_fd);
	close(f2_fd);
	close(f3_fd);
	exit(0);


}

//v2
#include <stdlib.h>
#include <err.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdint.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 4) {
        errx(1, "Expected 4 arguments");
    }

    const char* f1 = argv[1];
    const char* f2 = argv[2];
    struct stat s1;
    struct stat s2;

    if (stat(f1, &s1) == -1) {
        err(2, "Error while stat file %s", f1);
    }

    if (stat(f2, &s2) == -1) {
        err(3, "Error while stat file %s", f2);
    }

    uint32_t size1 = s1.st_size;
    uint32_t size2 = s2.st_size;

    if (size1 != size2) {
        errx(4, "files are not consistent %s, %s", f1, f2);
    }

    struct triple_t{
        uint16_t offset;
        uint8_t b1;
        uint8_t b2;
    }__attribute__((packed)); // Best possible alignment (i.e. remove padding)

    int fd1 = open(f1, O_RDONLY);
    int fd2 = open(f2, O_RDONLY);

    if (fd1 == -1) {
        errx(5, "ERROR: while opening %s", f1);
    }


    if (fd2 == -1) {
        const int _errno = errno;
        close(fd1);
        errno = _errno;
        errx(6, "ERROR: while opening file %s", f2);
    }

    const char* f3 = argv[3];
    int fd3 = open(f3, O_APPEND | O_CREAT | O_TRUNC | O_RDWR, S_IRWXU);

    if (fd3 == -1) {
        const int _errno = errno;
        close(fd1);
        close(fd2);
        errno = _errno;
        err(7, "ERROR: while opening file %s", f3);
    }

    ssize_t rd1 = -1;
    ssize_t rd2 = -1;
    struct triple_t p;

    for (p.offset = 0; p.offset < size1; p.offset++){
        if ( (rd1 = read(fd1, &p.b1, sizeof(p.b1))) != sizeof(p.b1)){
            close(fd1);
            close(fd2);
            close(fd3);
            errx(7, "ERROR: while reading file %s", f1);
        }

        if ( (rd2 = read(fd2, &p.b2, sizeof(p.b2))) != sizeof(p.b2)){
            close(fd1);
            close(fd2);
            close(fd3);
            errx(7, "ERROR: while reading file %s", f2);
        }

        if (p.b1 != p.b2){
            ssize_t wr = write(fd3, &p, sizeof(p));
            if ( wr == -1 || wr != sizeof(p)) {
                const int _errno = errno;
                close(fd1);
                close(fd2);
                close(fd3);
                errno = _errno;
                errx(8, "ERROR: while writing in %s", f3);
            }
        }
    }

    if (rd1 == -1 || rd2 == -1){
        const int _errno = errno;
        close(fd1);
        close(fd2);
        close(fd3);
        errno = _errno;
        errx(9, "ERROR: while reading from file %s and %s", f1, f2);
    }

    close(fd1);
    close(fd2);
    close(fd3);

    exit(0);
}

//Напишете програма на C, която приема три параметъра – имена на двоични файлове.
//Примерно извикване: $ ./main f1.bin f2.bin patch.bin
//        Файловете f1.bin и f2.bin се третират като двоични файлове, състоящи се от байтове (uint8_t).
//Файлът f1.bin e “оригиналният” файл, а f2.bin е негово копие, което е било модифицирано по някакъв начин (извън обхвата на тази задача).
//Файлът patch.bin е двоичен файл, състоящ се от наредени тройки от следните елементи (и техните типове): •
//отместване (uint16_t) – спрямо началото на f1.bin/f2.bin
//• оригинален байт (uint8_t) – на тази позиция в f1.bin • нов байт (uint8_t) – на тази позиция в f2.bin 18
//Вашата програма да създава файла patch.bin, на базата на съществуващите файлове f1.bin и f2.bin, като описва вътре само разликите между двата файла.
//Ако дадено отместване съществува само в единия от файловете f1.bin/f2.bin, програмата да прекратява изпълнението си по подходящ начин.
//
//Примерен f1.bin:
//00000000: f5c4 b159 cc80 e2ef c1c7 c99a 2fb0 0d8c ...Y......../...
//00000010: 3c83 6fed 6b46 09d2 90df cf1e 9a3c 1f05 <.o.kF.......<..
//00000020: 05f9 4c29 fd58 a5f1 cb7b c9d0 b234 2398 ..L).X...{...4#.
//00000030: 35af 6be6 5a71 b23a 0e8d 08de def2 214c 5.k.Zq.:......!L
//
//        Примерен f2.bin:
//00000000: f5c4 5959 cc80 e2ef c1c7 c99a 2fb0 0d8c ..YY......../...
//00000010: 3c83 6fed 6b46 09d2 90df cf1e 9a3c 1f05 <.o.kF.......<..
//00000020: 05f9 4c29 fd58 a5f1 cb7b c9d0 b234 2398 ..L).X...{...4#.
//00000030: afaf 6be6 5a71 b23a 0e8d 08de def2 214c ..k.Zq.:......!L
//
//        Примерен patch.bin:
//00000000: 0200 b159 3000 35af ...Y0.5.
