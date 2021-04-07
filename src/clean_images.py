#!/usr/bin/env python
# -*- coding:utf-8 -*-
__author__ = 'wangrong'
import os
import sys

if len(sys.argv) > 1:
    try:
        keep_image_nums=int(sys.argv[1])
    except ValueError:
        raise ValueError('Please make sure the input value is Integer Type')
    if keep_image_nums < 0:
        keep_image_nums = 0
else:
    keep_image_nums=1

dangling_images_cmd='''docker images -f "dangling=true" -q'''
dangling_images=os.popen(dangling_images_cmd).read().split()

# delete dangling images
if len(dangling_images) > 0:
    for one_dangling in dangling_images:
        del_dangling_image_cmd="docker rmi {}".format(one_dangling)
        print(del_dangling_image_cmd)
        print(os.popen(del_dangling_image_cmd).read())
# delete history image only keep specified image nums
need_clean_image_cmd='docker images -f "dangling=false" --format "{{.Repository}}:{{.Tag}}"'
need_clean_image_res=os.popen(need_clean_image_cmd).read().split()
need_clean_image={}
for one_res in need_clean_image_res:
    image_tag = one_res.split(":")[-1]
    image_name_len = len(one_res) - len(image_tag) - 1
    image_name = one_res[0:image_name_len]
    if image_name not in need_clean_image:
        need_clean_image[image_name]=[]
    need_clean_image[image_name].append(image_tag)

for one_image in need_clean_image:
    if len(need_clean_image[one_image]) > keep_image_nums:
        print("[CLEAN IMAGE] Image Name:{}, Maximum retain Nums:{}, Current Nums:{}".format(one_image,keep_image_nums,len(need_clean_image[one_image])))
        need_clean_image[one_image].sort()
        for one in range(0,len(need_clean_image[one_image])-keep_image_nums):
            clean_image_cmd='''docker rmi {}:{}'''.format(one_image,need_clean_image[one_image][one])
            print (clean_image_cmd)
            print(os.popen(clean_image_cmd).read())
