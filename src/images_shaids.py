import os
import sys
import time
import datetime
import re

if len(sys.argv) > 1:
    image_shaid_file=sys.argv[1]
else:
    image_shaid_file='/root/run/remote_shaid.lst'

get_all_none_dangling_image_addr='docker images -f "dangling=false" --format "{{.Repository}}:{{.Tag}}"'
all_none_dangling_image_res=os.popen(get_all_none_dangling_image_addr).read().split()
all_sha_id_list=[]
all_none_dangling_image={}
for one_image_addr in all_none_dangling_image_res:
    image_tag=one_image_addr.split(":")[-1]
    image_name_len = len(one_image_addr) - len(image_tag) - 1
    image_name = one_image_addr[0:image_name_len]
    if image_name not in all_none_dangling_image:
        all_none_dangling_image[image_name] = []
    all_none_dangling_image[image_name].append(image_tag)
#mytest:1.1
for one_image in all_none_dangling_image:
    latest_tag=max(all_none_dangling_image[one_image])
    latest_image_addr="{}:{}".format(one_image,latest_tag)
    shaid_cmd = 'docker inspect -f {{{{.RootFS.Layers}}}} {}'.format(latest_image_addr)
    sha_id_str = os.popen(shaid_cmd).read()
    sha_id_str = sha_id_str.replace('[', '').replace(']', '').strip()
    sha_id_list = sha_id_str.split(" ")
    print (">> Get IMAGE Shaid From: {}".format(latest_image_addr))
    for one_shaid in sha_id_list:
        #print("{}[{}]".format(latest_image_addr,one_shaid))
        if one_shaid not in all_sha_id_list:
            all_sha_id_list.append(one_shaid)

all_sha_id_list=[line+"\n" for line in all_sha_id_list]
with open(image_shaid_file,'w') as f:
    f.writelines(all_sha_id_list)

