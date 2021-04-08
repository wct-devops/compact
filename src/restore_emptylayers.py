#!/usr/bin/env python
# -*- coding:utf-8 -*-
import os
import sys
import json

DOCKER_IMAGE_HOME = "/var/lib/docker/image/overlay2/layerdb/sha256"
DOCKER_LAYER_HOME = "/var/lib/docker/overlay2"

LAYER_LIST = []
SHAID_LIST = []

IMAGE_DIR = os.sys.argv[1]

for file in os.listdir(IMAGE_DIR):
    if file[-5:] == '.json':
        if file == 'manifest.json':
            d = json.loads(open(os.path.join(IMAGE_DIR, file), 'rt').read())
            LAYER_LIST = d[0]["Layers"]
        else:
            d = json.loads(open(os.path.join(IMAGE_DIR, file), 'rt').read())
            SHAID_LIST = d["rootfs"]["diff_ids"]

for i in range(0, len(SHAID_LIST)):
    if os.path.getsize(os.path.join(IMAGE_DIR, LAYER_LIST[i])) == 0:
        cache_id = ''
        meta_file = ''
        for dir in os.listdir(DOCKER_IMAGE_HOME):
            diff_id = open(os.path.join(os.path.join(DOCKER_IMAGE_HOME, dir), "diff"), 'rt').read()
            if diff_id == SHAID_LIST[i]:
                cache_id = open(os.path.join(os.path.join(DOCKER_IMAGE_HOME, dir), "cache-id"), 'rt').read()
                meta_file = os.path.join(os.path.join(DOCKER_IMAGE_HOME, dir), "tar-split.json.gz")
        if cache_id == '':
            print("could not found diff layer in local")
            sys.exit(1)

        cmd = "./tar-split asm --output %s --input %s  --path %s/ " % (
        os.path.join(IMAGE_DIR, LAYER_LIST[i]), meta_file,
        os.path.join(os.path.join(DOCKER_LAYER_HOME, cache_id), "diff"))
        print(os.popen(cmd).read())