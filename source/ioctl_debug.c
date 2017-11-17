#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <error.h>
#include <errno.h>
#include <getopt.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>

int main(int argc, char *argv[]) {
	int option = 0, index = 0;
	int dir = _IOC_NONE, type = 0, nr = 0, size = 0;

	while((option = getopt(argc, argv, "hd:t:n:s:")) != -1) {
		switch(option) {
			case '?':
			case 'h':
			fprintf(stderr, "Usage: %s [-d <direction>] [-t <type>] [-n <nr>] [-s <size>] <device>\n", argv[0]);
			exit(1);
			break;
			case 'd':
			dir = strtol(optarg, NULL, 0);
			break;
			case 't':
			type = strtol(optarg, NULL, 0);
			break;
			case 'n':
			nr = strtol(optarg, NULL, 0);
			break;
			case 's':
			size = strtol(optarg, NULL, 0);
			break;
			default:
			break;
		}

	}
	
	for(index = optind; index < argc; index++) {
		int value = 0, result = 0, file = 0;

		printf("opening: %s\n", argv[index]);
		file = open(argv[index], O_RDWR | O_SYNC);

		if(file == -1) {
			error(1, errno, "error: cannot open device");
		}

		if(size > 0) {
			char *buffer = calloc(1, size), *bufferp = buffer;
			printf("size: %d\n", size);
			result = ioctl(file, (((dir) << _IOC_DIRSHIFT) | ((type) << _IOC_TYPESHIFT) | ((nr) << _IOC_NRSHIFT) | ((size) << _IOC_SIZESHIFT)), buffer);
			if(result < 0) {
				error(1, errno, "error: ioctl return code: %d", result);
			} else {
				while(size--) {
					printf("%02x ", *bufferp++);
				}
				printf("\n");
			}
			if(buffer) free(buffer);
		} else {
			result = ioctl(file, (((dir) << _IOC_DIRSHIFT) | ((type) << _IOC_TYPESHIFT) | ((nr) << _IOC_NRSHIFT) | ((size) << _IOC_SIZESHIFT)), 0);
			if(result < 0) {
				error(1, errno, "error: ioctl return code: %d", result);
			}
		}

		close(file);
	}

	exit(1);
}
