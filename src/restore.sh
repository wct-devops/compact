#!/bin/sh
. /root/functions.sh
cd $1
cp /root/tar-split ./
cp /root/docker_restore.py ./
cp /root/restore_emptylayers.py ./
python docker_restore.py
cd unfold
ls | while read IMAGE
do
    cd $IMAGE
    bold_echo "Restore Image From: $IMAGE "
    re=$(tar cf - . | docker load)
    image=${re#*:}
    if [ ! -n "$image" ];then
        cd ../../
        bold_echo "[$IMAGE] restore empty layer and retry ... "
        python restore_emptylayers.py unfold/$IMAGE
        cd unfold/$IMAGE
        re=$(tar cf - . | docker load)
        image=${re#*:}
    fi
    if [ ! -n "$image" ];then
        red_echo -n "[extract] " >> restore_image_list.txt
        echo -n  $IMAGE" -> " >> restore_image_list.txt
        red_echo " failed!" >> restore_image_list.txt
        red_echo -n "[extract] " >> restore_image_failed_list.txt
        echo -n  $IMAGE" -> " >> restore_image_failed_list.txt
        red_echo " failed!" >> restore_image_failed_list.txt
    else
        green_echo -n "[extract] " >> /root/run/restore_image_list.txt
        echo -n $IMAGE" -> "$image >> /root/run/restore_image_list.txt
        green_echo " success!" >> /root/run/restore_image_list.txt
    fi
    cd ..
done
cd /root/run/
rm -rf unfold
rm -f tar-split
rm -f docker_restore.py
rm -f restore_emptylayers.py
#ls -l
#echo -e "\n\033[1;44m FINISHED! Your can check the image list in the file [image_list].\033[0m\n"

