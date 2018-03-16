#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<fcntl.h>
#include<sys/ioctl.h>
#include<unistd.h>

/*
 * CLI utility to send ioctls to the PTZ driver
 *
 * Usage:
 * ptz <request> <arg0>
 *
 * Examples:
 * Pan left:     ptz 0x67 0x20
 * Tilt down:    ptz 0x66 0x20
 * Stop:         ptz 0x64 0x00
 * Get position: ptz 0x82 -1
 *
 */

int main(int argc, char **argv)
{
    if(argc < 3) {
        fprintf(stderr, "missing args!\n");
        return 1;
    }

    int a = (int)strtol(argv[1], NULL, 0);
    int b = (int)strtol(argv[2], NULL, 0);

    char c[128];
    memset(c, 0, 128);

    int fh = open("/dev/ptz", O_RDWR);
    if(fh == -1) {
        fprintf(stderr, "couldn't open device\n");
        return 1;
    }

    int r;
    if(b == -1) {
        // if arg0 was -1, pass a pointer to a buffer instead
        r = ioctl(fh, a, c);
    } else {
        r = ioctl(fh, a, b);
    }
    printf("ioctl(fh, %#x, %#x) = %d\n", a, b, r);

    // print buffer contents, if applicable
    if(b == -1) {
        for(int i = 0; i < 128; i++) {
            if(i > 0) {
                printf(" ");
            }
            printf("%02x", c[i]);
        }
        printf("\n");
    }

    r = close(fh);
    if(r == -1) {
        fprintf(stderr, "couldn't close device\n");
        return 1;
    }

    printf("done\n");
    return 0;
}
