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
#include <linux/limits.h>

char filename[PATH_MAX] = "/home/devParam.dat";

void param_get(size_t offset, size_t size) {
	char *buffer = calloc(1, size + 1), *bufferp = buffer;
	FILE *file = fopen(filename, "r+b");
	if(file == NULL) {
		free(buffer); error(1, errno, "error: cannot open file: %s", filename);
	}
	fseek(file, offset, SEEK_SET);
	fread(buffer, size, 1, file);
	while(size--) {
		printf("%02x ", *bufferp++);
	}
	printf("\n");
	fclose(file);
	free(buffer);
}

void param_get_string(size_t offset, size_t size) {
	char *buffer = calloc(1, size + 1);
	FILE *file = fopen(filename, "r+b");
	if(file == NULL) {
		free(buffer); error(1, errno, "error: cannot open file: %s", filename);
	}
	fseek(file, offset, SEEK_SET);
	fread(buffer, size, 1, file);
	printf("%s\n", buffer);
	fclose(file);
	free(buffer);
}

void param_set_int(size_t offset, size_t size, int data) {
	char *buffer = calloc(1, size + 1);
	FILE *file = fopen(filename, "r+b");
	if(file == NULL) {
		free(buffer); error(1, errno, "error: cannot open file: %s", filename);
	}
	memcpy(buffer, &data, size);
	fseek(file, offset, SEEK_SET);
	fwrite(buffer, size, 1, file);
	fclose(file);
	free(buffer);
}

void param_set_string(size_t offset, size_t size, char *data) {
	char *buffer = calloc(1, size + 1);
	FILE *file = fopen(filename, "r+b");
	if(file == NULL) {
		free(buffer); error(1, errno, "error: cannot open file: %s", filename);
	}
	strncpy(buffer, data, strlen(data)); // Potentially unsafe, but should be fine if coming from args
	fseek(file, offset, SEEK_SET);
	fwrite(buffer, size, 1, file);
	fclose(file);
	free(buffer);
}

int main(int argc, char *argv[]) {
	int option = 0, option_index = 0, index = 0;

	static struct option long_options[] =
	{
		{"help",  no_argument, 0, 'h'},
		{"filename",  required_argument, 0, 'f'},
		{"wifissid",  optional_argument, 0, 'w'},
		{"wifipass",  optional_argument, 0, 'k'},
		{"username",  optional_argument, 0, 'u'},
		{"password",  optional_argument, 0, 'p'},
		{"lowquality",  optional_argument, 0, 'q'},
		{"orientation",  optional_argument, 0, 'o'},
		{"nightvision",  optional_argument, 0, 'n'},
		{0, 0, 0, 0}
	};	

	while((option = getopt_long(argc, argv, "hf:w::k::u::p::q::o::n::", long_options, &option_index)) != -1) {
		switch(option) {
			case '?':
			case 'h':
			printf("Usage: %s [--filename=</home/devParam.dat>] [--wifissid[=string]] [--wifipass[=string]] [--username[=string]] [--password[=string]] [--lowquality[=number]] [--orientation[=number]] [--nightvision[=number]]\n\n", argv[0]);
			printf("\t -f, --filename                devParam.dat file to write to / read from\n");
			printf("\t                               Must come before other options (default: /home/devParam.dat)\n");
			printf("\t -n, --nightvisiom             Night vision ir led/cut (0: auto, 1: off, 2: on)\n");
			printf("\t -o, --orientation             Image orientation (0: 0deg, 3: 180deg)\n");
			printf("\t -q, --lowquality              Stream quality (0: hd, 1: nohd)\n");
			printf("\t -u, --username                Stream username (default: admin)\n");
			printf("\t -p, --password                Stream username (default: admin)\n");
			printf("\t -w, --wifissid                Wifi access point name / ssid\n");
			printf("\t -k, --wifipass                Wifi password / key\n");
			printf("\n\t Use \"--option=value\" to set value and just \"--option\" to get current value.\n");
			break;
			case 0:
				if(long_options[option_index].flag != 0)
					break;
				printf("option %s", long_options[option_index].name);
				if(optarg)
					printf (" with arg %s", optarg);
				printf("\n");
			break;
			case 'n':
			if(optarg) {
				param_set_int(0xf6, 1, strtol(optarg, NULL, 0));
			} else {
				param_get(0xf6, 1);
			}
			break;
			case 'o':
			if(optarg) {
				param_set_int(0xf8, 1, strtol(optarg, NULL, 0));
			} else {
				param_get(0xf8, 1);
			}
			break;
			case 'q':
			if(optarg) {
				param_set_int(0xec, 1, strtol(optarg, NULL, 0));
			} else {
				param_get(0xec, 1);
			}
			break;
			case 'w':
			if(optarg) {
				param_set_string(0x128, 32, optarg);
			} else {
				param_get_string(0x128, 32);
			}
			break;
			case 'k':
			if(optarg) {
				param_set_string(0x154, 8, optarg);
			} else {
				param_get_string(0x154, 8);
			}
			break;
			case 'u':
			if(optarg) {
				param_set_string(0x1fc, 16, optarg);
			} else {
				param_get_string(0x1fc, 16);
			}
			break;
			case 'p':
			if(optarg) {
				param_set_string(0x20c, 16, optarg);
			} else {
				param_get_string(0x20c, 16);
			}
			break;
			case 'f':
			snprintf(filename, PATH_MAX, "%s", optarg);
			break;
			default:
			break;
		}

	}
	
	exit(1);
}
