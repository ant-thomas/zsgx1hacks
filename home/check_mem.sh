#check if uboot mem size need to change
getMemArg()
{
        grep $1 /proc/cmdline | awk '{printf $2}'
}

cd /home
if [ -f /tmp/sc2135 ]; then
        mem_arg=$(getMemArg mem)
        if [  "$mem_arg" = "mem=40M" ]; then
                echo "found 1080p, modify uboot args! reboot..."
		./chmemcfg 1080_mem_cfg.bin
		rm /home/devParam.dat
		reboot
		sleep 10
        fi
fi
