#!/bin/sh
. /root/functions.sh
remote_file=$1
if [ ! -n "$remote_file" ]; then
    remote_list_file=remote_$(hostname).lst
elif [ $remote_file == 'remote.lst' ];then
    remote_list_file=remote_$(hostname).lst
else
    remote_list_file=$remote_file
fi
python /root/images_shaids.py /root/run/$remote_list_file
bold_echo -n "images shaid file: $remote_list_file "
green_echo "generate success!"

