#!/bin/sh
. /root/functions.sh
IMAGE_LIST=$1
WORK_PATH=$2
REMOTE_LST=$3

if [ ! -d /root/run/$WORK_PATH ]; then
  mkdir -p /root/run/$WORK_PATH
fi

cd /root/run/$WORK_PATH
mkdir -p /root/run/$WORK_PATH/summary
cp /root/tar-split ./
cp /root/docker_merger.py ./
python /root/multipule_process_download.py $IMAGE_LIST
if [ "$?" -ne 0 ]; then
    red_echo "Download Image From $IMAGE_LIST Failed!"
    exit 1
fi
## image-tmp 来源于multipule_process_download.py处理生成，后续1.4版本，改成全python形式
cat image-tmp |while read line
do
         image=`echo $line |sed 's#/#-#g'`
         echo "PROCESSING:"$line"->"$image
         mkdir -p unfold/$image
         #docker pull $line
         echo "SAVE $line to DIR:unfold/$image"
         docker save $line | tar -C unfold/$image -x
         if [ "$?" -ne 0 ]; then
             red_echo "Maybe Image: $line not exist, Will exit ... Please Check!"
             exit 1
         fi
         echo $line >> summary/summary_compact_result.txt
done

if [ "$?" -ne 0 ];  then
    exit 
fi

green_echo "[`date +%F" "%T`] merge&compress images with ${REMOTE_LST} ... "
if [ ! -f ${REMOTE_LST} ];then
  cp /root/run/${REMOTE_LST} ./
fi

python docker_merger.py ${REMOTE_LST}
if [ "$?" -ne 0 ];  then
    exit
fi

python /root/images_shaid.py image-tmp

rm tar-split
rm docker_merger.py
rm -rf unfold
mv image-tmp $IMAGE_LIST
chmod a+rx *
echo "[compact] compact result:`ls -l`"

