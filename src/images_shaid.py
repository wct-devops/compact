#!/usr/bin/env python
# -*- coding:utf-8 -*-
__author__ = 'wangrong'
import os
import sys

if len(sys.argv) > 1:
    image_file=sys.argv[1]
else:
    print('\033[31m[ERROR] Please specified image list file!\033[0m')
    exit(1)

image_list=[]
with open(image_file,'r') as f:
    for line in f.readlines():
        image_list.append(line.strip())

if len(image_list) <= 0:
    print("[Warning]Image list file is empty!")
    exit(1)

all_sha_id_list=[]
for one_image_addr in image_list:
    shaid_cmd='docker inspect -f {{{{.RootFS.Layers}}}} {}'.format(one_image_addr)
    print("load image [{}] shaid into file ...".format(one_image_addr))
    sha_id_str = os.popen(shaid_cmd).read()
    sha_id_str = sha_id_str.replace('[', '').replace(']', '').strip()
    sha_id_list=sha_id_str.split(" ")
    for one_shaid in sha_id_list:
        #print("{}[{}]".format(one_shaid, one_image_addr))
        if one_shaid not in all_sha_id_list:
            all_sha_id_list.append(one_shaid)

all_sha_id_list=[line+"\n" for line in all_sha_id_list]
with open('summary/summary_compact_images_id.lst','w') as f:
    f.writelines(all_sha_id_list)