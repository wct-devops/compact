#!/bin/sh
VERSION="v1.3.1"
# shell脚本的所在绝对路径
currentdir=$(cd $(dirname $0); pwd)
mode=$1
PART1=$2
PART2=$3
PART3=$4
######
SEND_MSG_FLAG=0
start_date=`date +%s`
###########

PROGNAME="${0##*/}"
PROGVERSION="${VERSION}"
#Colors variables
SETCOLOR_GREEN="echo -en \\033[0;32m"
SETCOLOR_RED="echo -en \\033[0;31m"
SETCOLOR_YELLOW="echo -en \\033[0;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
SETSTYLE_BOLD="echo -en \\033[1m"
SETSTYLE_UNDERLINE="echo -en \\033[4m"
SETSTYLE_NORMAL="echo -en \\033[0m"
enable_colors="${enable_colors:-true}"

#######function
function red_echo() {
  #in order for the -n functionality to work properly $2 must be quoted when called in case of spaces
  if "${enable_colors}";then
    if [ "$1" = "-n" ];then
      ${SETCOLOR_RED} && echo -n "$2" && ${SETCOLOR_NORMAL}
    else
      ${SETCOLOR_RED} && echo "$*" && ${SETCOLOR_NORMAL}
    fi
  else
    if [ "$1" = "-n" ];then
      echo -n "$2"
    else
      echo "$*"
    fi
  fi
}

function green_echo() {
  #in order for the -n functionality to work properly $2 must be quoted when called in case of spaces
  if "${enable_colors}";then
    if [ "$1" = "-n" ];then
      ${SETCOLOR_GREEN} && echo -n "$2" && ${SETCOLOR_NORMAL}
    else
      ${SETCOLOR_GREEN} && echo "$*" && ${SETCOLOR_NORMAL}
    fi
  else
    if [ "$1" = "-n" ];then
      echo -n "$2"
    else
      echo "$*"
    fi
  fi
}

function yellow_echo() {
  #in order for the -n functionality to work properly $2 must be quoted when called in case of spaces
  if "${enable_colors}";then
    if [ "$1" = "-n" ];then
      ${SETCOLOR_YELLOW} && echo -n "$2" && ${SETCOLOR_NORMAL}
    else
      ${SETCOLOR_YELLOW} && echo "$*" && ${SETCOLOR_NORMAL}
    fi
  else
    if [ "$1" = "-n" ];then
      echo -n "$2"
    else
      echo "$*"
    fi
  fi
  return 0
}

#same as echo function except output bold text
function bold_echo() {
  #in order for the -n functionality to work properly $2 must be quoted when called in case of spaces
  if "${enable_colors}";then
    if [ "$1" = "-n" ];then
      ${SETSTYLE_BOLD} && echo -n "$2" && ${SETSTYLE_NORMAL}
    else
      ${SETSTYLE_BOLD} && echo "$*" && ${SETSTYLE_NORMAL}
    fi
  else
    if [ "$1" = "-n" ];then
      echo -n "$2"
    else
      echo "$*"
    fi
  fi
  return 0
}

function fun_send_msg(){
msg=$1
if [ $SEND_MSG_FLAG -gt 0 ]; then
        curl 'https://oapi.dingtalk.com/robot/send?access_token=98ee3667f6ecd8571334054106a2251910ee798dc1dffa740f72bd189404b3d3' \
           -H 'Content-Type: application/json' \
           -d '
          {"msgtype": "markdown",
                "markdown": {
                        "title": "打包镜像通知",
                        "text": "## '$msg' \n\n > ###### [ notice from 80.66 ]发布 \n"
                 },
                "at": {
                        "atMobiles": [""],
                        "isAtAll": true
                }
          }'
else
        echo -e "$msg"
fi

}

function fun_use_hours(){
    if [ $# -ne 2 ];then
        echo $@
        echo "usage:  fun_use_hours <start_date> <end_date>"
        echo " eg: fun_use_hours 1533274262 1533274263"
        echo " start_date 开始时间"
        echo " end_date 结束时间"
        return 1
    else
        start=$1
        end=$2
        start_s=$(echo $start | cut -d '.' -f 1)
        start_ns=$(echo $start | cut -d '.' -f 2)
        end_s=$(echo $end | cut -d '.' -f 1)
        end_ns=$(echo $end | cut -d '.' -f 2)
        use_time=$(( ( 10#$end_s - 10#$start_s ) * 1000 + ( 10#$end_ns / 1000000 - 10#$start_ns / 1000000 ) ))

        if [ $use_time -lt 1000 ];then
            echo "0:0:0:${use_time}"
        else
            local hour=$(( ${use_time}/3600000 ))
            local min=$(( (${use_time}-${hour}*3600000)/60000 ))
            local sec=$(( (${use_time}-${hour}*3600000-${min}*60000)/1000 ))
            cost_string=${hour}:${min}:${sec}
        fi
        return 0
    fi
}

function extract_images() {
    bold_echo "[Extract] Begin Extract images..."
    cd $1
    if [ ! -f "images.squashfs" ] || [ ! -f "restore_layers.sh" ]
    then
        red_echo "images.squashfs or restore_layers.sh not found in [$1]!"
        exit
    fi
    workdir=`pwd`
    freespace=`df -m $workdir |awk 'NR==2{print $4}'`
    filesize=`du -m images.squashfs  | awk '{print $1}'`
    requirespace=$((6*filesize))
    if ((${freespace} < ${requirespace}))
    then
        red_echo "$workdir storage is insufficient for extract!!!,the directory at least $requirespace M free space"
        exit
    fi
    order="docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -v ${workdir}:/root/run zcm-compact:${PROGVERSION} extract"
    $order
    end_date=`date +%s`
    fun_use_hours $start_date  $end_date
    msg_text2="[Extract] Complete! Extract image list:"${workdir}"/restore_image_list, Cost Time:"$cost_string
    green_echo $msg_text2
}

function compact_images() {
    bold_echo "[Compact] Begin Compact images..."
    if [ ! -f $1 ];then
        red_echo "image list file: $1 not found, Please check it again"
        exit
    elif [ ! -n "$2" ];then
        remote_lst="remote.lst"
        rm -f remote.lst && touch remote.lst
    else
        if [ ! -f $2 ];then
            red_echo "remote list file:$2 not found, please check it again"
            exit
        fi
        remote_lst=$2

    fi
    image_lst=$1

    compress_file=${image_lst##*/}
    remote_file=${remote_lst##*/}
    workdir=$currentdir/${image_lst%/*}
    remote_dir=$currentdir/${remote_lst%/*}

    if [ ! -d $workdir ];then
        workdir=$currentdir
    fi
    if [ ! -d $remote_dir ];then
        remote_dir=$currentdir
    fi

    compact_dir="IMAGE_${compress_file%.*}""_$(date +%Y%m%d%H%M)"
    if [ -d $workdir/$compact_dir ]
    then
        red_echo "Same work path [$compact_dir], duplicate work ?"
        exit
    else
        mkdir -p $workdir/$compact_dir
    fi

    if [ ! -f $remote_dir/$remote_file ];then
        red_echo "remote file: $remote_dir/$remote_file not found!"
        exit
    fi
    cp -f $image_lst $workdir/$compact_dir/
    cp -f $remote_dir/$remote_file $workdir/$compact_dir/
    order="docker run --rm --hostname=$(hostname) -v /var/run/docker.sock:/var/run/docker.sock -v ${workdir}:/root/run zcm-compact:${PROGVERSION} compact ${compress_file} ${compact_dir} ${remote_file}"
    $order

    end_date=`date +%s`
    fun_use_hours $start_date  $end_date
    msg_text2="[Compact] Complete! Compact Dir:"$workdir/$compact_dir", Cost Time:"$cost_string
    green_echo $msg_text2

}

function clean_images(){
    bold_echo "[Clean] Clean Images ..."
    remain_nums=$1
    order="docker run --rm --hostname=$(hostname) -v /var/run/docker.sock:/var/run/docker.sock zcm-compact:${PROGVERSION} clean $remain_nums"
    $order

    end_date=`date +%s`
    fun_use_hours $start_date  $end_date
    green_echo "[Clean] Complete! Cost Time:"$cost_string
}

function get_images_shaid(){
    bold_echo "[GetShaid] Get Images Shaid ..."
    workdir=$currentdir
    remote_file=$1
    order="docker run --rm --hostname=$(hostname) -v /var/run/docker.sock:/var/run/docker.sock -v $workdir:/root/run zcm-compact:${PROGVERSION} shaid $remote_file"
    $order

    end_date=`date +%s`
    fun_use_hours $start_date  $end_date
    green_echo "[GetShaid] Complete! Image Shaid File Stored in: ${workdir} Cost Time:"$cost_string
}

function rename_images(){
    bold_echo "[Rename] Begin Rename images..."
    if [ ! -f $1 ];then
        red_echo "image list file: $1 not found, Please check it again"
        exit
    elif [ ! -f $2 ];then
         red_echo "remote list file:$2 not found, please check it again"
         exit
    fi
    image_lst=$1
    harbor_cfg=$2
    if [ ! -n "$3" ]; then
        operate="ALL"
    elif [ "$3" == "only" ]; then
        operate="only"
    else
        red_echo "Unsupport Operation Type, please get help info from <${PROGNAME} help>"
    fi
    image_file=${image_lst##*/}
    harbor_file=${harbor_cfg##*/}
    workdir=$currentdir/${image_lst%/*}
    harbor_dir=$currentdir/${harbor_cfg%/*}

    if [ ! -d $workdir ];then
        workdir=$currentdir
    fi
    if [ ! -d $harbor_dir ];then
        harbor_dir=$currentdir
    fi

    rename_dir="REM_"`date +%Y%m%d%H%M`
    if [ -d $workdir/$rename_dir ]
    then
        red_echo "Same work path [$rename_dir], duplicate work ?"
        exit
    else
        mkdir -p $workdir/$rename_dir
    fi

    cp -f $image_lst $workdir/$rename_dir/
    cp -f $harbor_dir/$harbor_file $workdir/$rename_dir/
    order="docker run --rm --hostname=$(hostname) -v /var/run/docker.sock:/var/run/docker.sock -v ${workdir}/${rename_dir}:/root/run zcm-compact:${PROGVERSION} rename $image_file $harbor_file $operate"
    $order

    end_date=`date +%s`
    fun_use_hours $start_date  $end_date
    green_echo "[Rename] Complete! Renamed image list:${workdir}/rename_images.txt Cost Time:"$cost_string
}

function version_info(){
    bold_echo "${PROGNAME} ${PROGVERSION}"
    exit 1
}

function help_info(){
    cat <<EOF
${PROGNAME} ${PROGVERSION} - MIT License by ZCM DevOps Group
USAG:
    ${PROGNAME} MODE [PART1] [PART2]
DESCRIPTION:
    -h,--help,help  Show help info
    -v,version      Show program version
OPERATION MODE:
    At least one operation MODE is required.
    extract     extract images
        extract <images dir>    ==>extract compressed files to images

    compact     compact images
        compact <compact images file>                     ==>compact images from given image list file
        compact <compact images file> [remote shaid file] ==>increment compact images by using specified remote shaid

    shaid       generate current server all image shaid in file
        shaid                       ==> generate current server images shaid in remoate-`hostname`.lst file
        shaid [remote-server.lst]   ==> generate current server images shaid in specified file

    clean       clean current server images only keep one image for per same image in default
        clean       ==> clean current server images only keep 1 image for per same image
        clean [3]   ==> clean current server images only keep specified images for per same image

    rename      rename the given images to specified && push them to harbor
        rename <images list file> <harbor config file>          ==> rename the given images to specified && push them to harbor
        rename <images list file> <harbor config file> [only]   ==> only rename the given images to specified
 ===========
 NOTICE:
 For support, bug reporting and feedback about the provided Tool, please open an [issue on Gitlab](http://gitlab.iwhalecloud.com/cloud/zcm-compact/issues).
EOF
}

function pre_check(){
    bold_echo "check image: <zcm-compact:${PROGVERSION}>"
    pre_image_cnt=`docker images|grep zcm-compact|grep ${PROGVERSION}|wc -l`
    if [ $pre_image_cnt -le 0 ]; then
        red_echo "image: <zcm-compact:${PROGVERSION}> not found! Please Contact ZCM Team!"
        exit
    fi
}


if [ $# -le 0 ]
then
    red_echo "Unexpected command, Please review the help info"
    help_info
    exit
fi
pre_check
case $mode in
    extract)
        extract_images $PART1
    ;;
    compact)
        compact_images $PART1 $PART2
    ;;
    clean)
        clean_images $PART1
    ;;
    shaid)
        get_images_shaid $PART1
    ;;
    rename)
        rename_images $PART1 $PART2 $PART3
    ;;
    version|-v|--version)
        version_info
    ;;
    help|-h|--help)
        help_info
    ;;
esac
