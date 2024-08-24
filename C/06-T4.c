#include <stdio.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

int main (int argc, char* argv[]) {
    if (argc != 3) {
        errx(1, "Usage: %s <file1> <file2>", argv[0]);
    }

    int fd1 = open(argv[1], O_RDWR);
    if (fd1 == -1) {
        err(2, "Can't open file: %s", argv[1]);
    }

    int fd2 = open(argv[2], O_RDWR);
    if (fd2 == -1) {
        close(fd1);
        err(3, "Can't open file: %s", argv[2]);
    }

    int fd3 = open("my_temp_file", O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR);
    if (fd3 == -1) {
        close(fd1);
        close(fd2);
        err(4, "Can't create temporary file");
    }

    char c[4096];
    ssize_t read_size;

    // Copy file1 to temp file
    while ((read_size = read(fd1, c, sizeof(c))) > 0) {
        if (write(fd3, c, read_size) != read_size) {
            close(fd1);
            close(fd2);
            close(fd3);
            err(5, "Error writing to temporary file");
        }
    }
    if (read_size < 0) {
        close(fd1);
        close(fd2);
        close(fd3);
        err(6, "Error reading from file: %s", argv[1]);
    }

    if (lseek(fd1, 0, SEEK_SET) == -1) {
        close(fd1);
        close(fd2);
        close(fd3);
        err(7, "Error seeking in file: %s", argv[1]);
    }

    // Copy file2 to file1
    while ((read_size = read(fd2, c, sizeof(c))) > 0) {
        if (write(fd1, c, read_size) != read_size) {
            close(fd1);
            close(fd2);
            close(fd3);
            err(8, "Error writing to file: %s", argv[1]);
        }
    }
    if (read_size < 0) {
        close(fd1);
        close(fd2);
        close(fd3);
        err(9, "Error reading from file: %s", argv[2]);
    }

    if (lseek(fd2, 0, SEEK_SET) == -1 || lseek(fd3, 0, SEEK_SET) == -1) {
        close(fd1);
        close(fd2);
        close(fd3);
        err(10, "Error seeking in files");
    }

    // Copy temp file to file2
    while ((read_size = read(fd3, c, sizeof(c))) > 0) {
        if (write(fd2, c, read_size) != read_size) {
            close(fd1);
            close(fd2);
            close(fd3);
            err(11, "Error writing to file: %s", argv[2]);
        }
    }
    if (read_size < 0) {
        close(fd1);
        close(fd2);
        close(fd3);
        err(12, "Error reading from temporary file");
    }

    close(fd1);
    close(fd2);
    close(fd3);

    exit(0);
}
