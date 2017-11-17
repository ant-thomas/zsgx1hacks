all: unbuffer.so goke_volume goke_p2pcam_param ioctl_debug

unbuffer.so: unbuffer.c
	$(CC) $< -std=gnu99 -fPIC -O2 -shared  -o $@

goke_p2pcam_param: goke_p2pcam_param.c
	$(CC) $< -std=gnu99 -fPIC -O2 -o $@

goke_volume: goke_volume.c
	$(CC) $< -std=gnu99 -fPIC -O2 -o $@

ioctl_debug: ioctl_debug.c
	$(CC) $< -std=gnu99 -fPIC -O2 -o $@

.PHONY: clean

clean:
	rm -f goke_p2pcam_param 
	rm -f goke_volume 
	rm -f ioctl_debug
	rm -f unbuffer.so
