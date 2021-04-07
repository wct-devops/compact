#!/bin/sh

mode=$1
p1=$2
p2=$3
p3=$4

if [ $mode = "extract" ]
then
    mkdir -p /root/run/logs
    sh /root/restore.sh /root/run |tee /root/run/logs/extract.log
elif [ $mode = "compact" ]
then
    compress_list=$p1
    compress_dir=$p2
    remote_lst=$p3
    mkdir -p /root/run/${compress_dir}/logs
    #order="sh /root/compress.sh /root/run/${compress_list} ${compress_dir} ${remote_lst} |tee /root/run/${compress_dir}/logs/compact.log"
    #$order
    sh /root/compress.sh /root/run/${compress_list} ${compress_dir} ${remote_lst} |tee /root/run/${compress_dir}/logs/compact.log
elif [ $mode = "clean" ]
then
    remain_nums=$p1
    python /root/clean_images.py ${remain_nums}
elif [ $mode = "shaid" ]
then
    remote_file=$p1
    sh /root/get_images_shaid.sh $remote_file
elif [ $mode = "rename" ]
then
    image_list=$p1
    harbor_cfg=$p2
    operation=$p3
    sh /root/rename_images.sh $image_list $harbor_cfg $operation
fi
