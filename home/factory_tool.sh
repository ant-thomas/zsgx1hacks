#!/bin/sh  

echo exec factory_tool.sh .......

select_first_one()
{
	ls $1 | awk 'FNR==1'
}

MNTPT=/mnt
USERDIR=/home
	
cfg_ini=`ls $MNTPT/*-hwcfg.ini`
voice_file=`ls $MNTPT/*-VOICE.tgz`
ptz_cfg=`ls $MNTPT/*-ptz.cfg`
hard_info=`ls $MNTPT/*-hardinfo.bin`
	
# hwcfg.ini: modifiable by customer
if [ "$cfg_ini" != "" ]; then
  cp -f $cfg_ini $USERDIR/hwcfg.ini
  if [ $? -ne 0 ]; then
    echo "Copy hwcfg.ini failed." > $MNTPT/ERROR.txt
    exit;
  fi
fi

# VOICE.tgz: for oversea or custom define voice
if [ "$voice_file" != "" ]; then
  cp -f $voice_file $USERDIR/VOICE.tgz
  if [ $? -ne 0 ]; then
    echo "Copy VOICE.tgz failed." > $MNTPT/ERROR.txt
    exit;
  fi
fi

# ptz.cfg: maybe use hwcfg.ini ptz section
if [ "$ptz_cfg" != "" ]; then
  cp -f $ptz_cfg $USERDIR/ptz.cfg
  if [ $? -ne 0 ]; then
    echo "Copy ptz.cfg failed." > $MNTPT/ERROR.txt
    exit;
  fi
fi

# hardinfo.bin: for different hardware
if [ "$hard_info" != "" ]; then
  cp -f $hard_info $USERDIR/hardinfo.bin
  if [ $? -ne 0 ]; then
    echo "Copy hardinfo failed." > $MNTPT/ERROR.txt
    exit;
  fi
fi

#
# uid file
#
if [ -f $USERDIR/eye.conf ]; then
  echo "eye.conf already existed !" > $MNTPT/INFO.txt
else 
  file_path=$(select_first_one $MNTPT/eyeconf/*.conf)

  if [ "$file_path" != "" ] ; then
    echo $file_path
    
    #avoid p2pcam auto format tf card!!!
    rm -f /bin/mkdosfs
    rm -f /sbin/mkdosfs

    mv $file_path $USERDIR/eye.conf
    if [ $? -ne 0 ]; then
      echo "Move to eye.conf failed" > $MNTPT/ERROR.txt
      exit
    else
      rm -f $MNTPT/ERROR.txt
    fi
  fi
fi

