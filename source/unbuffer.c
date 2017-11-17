#include <stdio.h>

// Source: https://lists.debian.org/debian-boot/2014/06/msg00089.html

__attribute__ ((constructor)) void stdbuf() {
	setvbuf (stdout, NULL, _IOLBF, 0);
}
