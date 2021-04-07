#!/usr/bin/env python
# -*- coding:utf-8 -*-
__author__ = 'wangrong'

from multiprocessing import Pool
import sys
import os

def pull_images(image_addr):
    print (">> Pull IMAGE: {} quiet".format(image_addr))
    pull_cmd='docker pull -q {}'.format(image_addr)
    #print (pull_cmd)
    print(os.popen(pull_cmd).read())
    #print ("pull {} complete!".format(image_addr))

def parallel_run(image_list):
    p=Pool(5)
    for one_image in image_list:
        p.apply_async(pull_images,args=(one_image,))
    #print ("Wait All subprocess Complete!")
    p.close()
    p.join()
    print("Download All Images Complete!")

def verify_image(image_list):
    get_all_image_list_cmd='''docker images --format "{{.Repository}}:{{.Tag}}"|grep -v "<none>"'''
    get_all_image_list=os.popen(get_all_image_list_cmd).read().split()
    not_found_image=[]
    for one_image in image_list:
        if one_image not in get_all_image_list:
            not_found_image.append(one_image)
            print('\033[31m[ERROR]>> [{}] Not Found!\033[0m'.format(one_image))
    if len(not_found_image) > 0:
        with open('summary/summary_compact_missing_images.lst','w+') as f:
            not_found_image = [line + "\n" for line in not_found_image]
            f.writelines(not_found_image)
        print("\033[31mImages Download Failed!\033[0m")
        print('\033[31m[ERROR] Some Image Not Found in Harbor, Please find the result in summary_compact_missing_images.lst!\033[0m')
        exit(1)
    print("\033[32mAll Images Download Success!\033[0m")

if len(sys.argv) > 1:
    image_file=sys.argv[1]
else:
    print('\033[31m[ERROR] Please Specified Image List file!\033[0m')
    exit(1)

image_list=[]
with open(image_file,'r') as f:
    for line in f.readlines():
        if line.strip():
            image_list.append(line.strip())
parallel_run(image_list)
verify_image(image_list)
image_list=[line+"\n" for line in image_list]
with open('image-tmp','w') as f:
    f.writelines(image_list)
