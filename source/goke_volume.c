#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <getopt.h>
#include <string.h>
#include <linux/kd.h>
#include <linux/vt.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <error.h>
#include <pthread.h>
#include <unistd.h>

void volume_get() {
	int value = 0;
	int result = 0, file = 0;
	file = open("/dev/ao_dev", O_RDWR | O_SYNC);
	if(file == -1) {
		error(1, errno, "error: cannot open device");
	}
	result = ioctl(file, _IOC(_IOC_READ, 0x59, 0x18, 0x4), &value);
	if(result >= 0) {
		printf("%02x\n", value);
	} else {
		error(1, errno, "error: ioctl return code: %d", result);
	}
	close(file);
}

void volume_set(int value) {
	int result = 0, file = 0;
	file = open("/dev/ao_dev", O_RDWR | O_SYNC);
	if(file == -1) {
		error(1, errno, "error: cannot open device");
	}
	result = ioctl(file, _IOC(_IOC_WRITE, 0x59, 0x17, 0x4), &value);
	if(result < 0) {
		error(1, errno, "error: ioctl return code: %d", result);
	}
	close(file);
}

int main(int argc, char *argv[]) {
	int option = 0;
	while((option = getopt(argc, argv, "hgs:")) != -1) {
		switch(option) {
			case '?':
			case 'h':
			fprintf(stderr, "%s [-g] [-s <volume>]\n", argv[0]);
			exit(1);
			break;
			case 's':
			volume_set(strtol(optarg, NULL, 0));
			break;
			case 'g':
			volume_get();
			break;
			default:
			break;
		}

	}

	exit(1);
}
