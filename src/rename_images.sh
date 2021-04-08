#!/bin/sh
. /root/functions.sh
# Include all user options and dependencies
image_lst=$1
harbor_cfg=$2
oper_type=$3
sh /root/run/$harbor_cfg
remote_harbor_prefix=$dest_harbor_ip/$dest_harbor_project
# get all images
echo "$dest_harbor_password"|docker login -u $dest_harbor_username --password-stdin $dest_harbor_ip

cat /root/run/$image_lst |while read line
do
        image_name= ${line##*/}
        bold_echo "PROCESSING:-> "$line
        docker tag $line $remote_harbor_prefix/$image_name
        if [ "$?" -ne 0 ];
        then
          red_echo "Original Image: $line not exist,please check!"
          exit 1
        fi
        if [ "$oper_type" == "ALL" ];then
            docker push $remote_harbor_prefix/$image_name
        fi
        #bold_echo -n "Rename $line to $remote_harbor_prefix/$image_name success! " >> /root/run/rename_images.txt
        bold_echo -n "Rename " >> /root/run/rename_images.txt
        yellow_echo -n $line >> /root/run/rename_images.txt
        bold_echo -n " to " >> /root/run/rename_images.txt
        yellow_echo -n $remote_harbor_prefix/$image_name >> /root/run/rename_images.txt
        green_echo " success! " >> /root/run/rename_images.txt
done