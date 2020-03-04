#!/bin/sh
currentdir=$(cd $(dirname $0); pwd)
mode=$1
dir=$2


if [ ! -n "$1" ]
then
    echo -e "\n\n\n\033[1;44mUSAGE:\033[0m\\n\n"
    echo -e "  1.restore the file to images:\n  sh zcm-compact.sh extract \033[1;44mnew_directory_name\033[0m\n"
    echo -e "  Please find a directory with enough space like \"/zpaas/zcm/compact\" as a dedicated decompression path,
  the first time you use , put zcm-compact.sh in it.
  Each time you want to extract,you should create a new directory like \"20190912\" in this path,
  put images.squashfs,restore_layers.sh into the new directory, 
  then you can execute the  command  to restore the file to images.\n"
    echo -e "  For example,\n  \033[1;44msh zcm-compact.sh extract 20190912\033[0m\n"                    
    echo -e "  /zpaas/zcm/compact/"
    echo -e "      ├──── zcm-compact.sh"
    echo -e "      └──── 20190912"
    echo -e "            ├────images.squashfs"
    echo -e "            └────restore_layers.sh\n\n"
    echo -e "  2.compress images:\n  sh zcm-compact.sh compact \033[1;44mnew_directory_name/filename.lst\033[0m\n"
    echo -e "  Please pull the image on the machine,edit the images' names as a list ends with '.lst', such as \"201909.lst\".
  Find a directory with enough space like \"/zpaas/zcm/compact\" as a dedicated decompression path,
  the first time you use , put zcm-compact.sh in it,
  Each time you want to compress,you should create a new directory like \"20190913\" in this path ,
  put the list into the new directory,
  then you can execute the  command to compress images.
  After execution,a directory will be automatically created based on the current time like \"IMAGE_1909130930\" in the \"20190913\" , 
  and the compressed file \"images.squashfs\",\"restore_layers.sh\" will be generated in the \"IMAGE_1909130930\".\n"
    echo -e "  For example,\n  \033[1;44msh zcm-compact.sh compact 20190913/201909.lst\033[0m\n"
    echo -e "  /zpaas/zcm/compact/"
    echo -e "      ├──── zcm-compact.sh"
    echo -e "      └──── 20190913"
    echo -e "            ├────201909.lst"
    echo -e "            └────IMAGE_1909130930"
    echo -e "                 ├─images.squashfs"
    echo -e "                 └────restore_layers.sh\n\n"
    exit
elif [ $mode = "extract" ]
then
    workdir=$currentdir/$dir
    cd $workdir
    if [ ! -f "images.squashfs" ] || [ ! -f "restore_layers.sh" ]
    then 
    echo -e "\nimages.squashfs or restore_layers.sh not found!\n"
    exit
    fi
    freespace=`df -m $workdir |awk 'NR==2{print $4}'`
    filesize=`du -m images.squashfs  | awk '{print $1}'`
    requirespace=$((7*filesize))   
    if ((${freespace} < ${requirespace})) 
    then
        echo "$workdir has no enough space for extract!!!,the dir must have $requirespace M free space"
        exit
    fi
    order="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ${workdir}:/root/run zcm-compact extract"
    $order
elif [ $mode = "compact" ]
then
    file=${dir##*/}
    workdir=$currentdir/${dir%/*}
    cd $workdir
    if [ ! -f $file ]
    then
    echo -e "\nThe image list: $file  not found!\n"
    exit
    fi
    if [ ! -n "$dir" ]
    then
        echo -e "\nUnexpected command,you can execute '\033[1;44msh zcm-compact.sh\033[0m' to learn how to use this script.\n"
        exit
    fi
    order="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v ${workdir}:/root/run zcm-compact compact ${file}"
    $order
else
    echo -e "\nUnexpected command,you can execute '\033[1;44msh zcm-compact.sh\033[0m' to learn how to use this script.\n"
fi
