import os
import sys

UNFOLD_DIR = "unfold"
SHARED_DIR = os.path.join(UNFOLD_DIR, "shared" ) 

cmd = "unsquashfs images.squashfs && rm -rf unfold && mv squashfs-root unfold"
print(cmd)
print(os.popen(cmd).read())

if os.path.exists(SHARED_DIR) == False:
    sys.exit()

for filename in os.listdir(SHARED_DIR):
    if filename[-13:] == '_meta.json.gz' :
        shaid = filename[:-13]
        shared_shaid_path = os.path.join(SHARED_DIR, shaid)
        cmd = "./tar-split asm --output %s.tar --input %s_meta.json.gz  --path %s/ && rm -rf %s/"%( shared_shaid_path, shared_shaid_path, shared_shaid_path , shared_shaid_path)
        print(cmd)
        print(os.popen(cmd).read())

cmd = "sh restore_layers.sh && rm -rf %s"%SHARED_DIR

print(cmd)
print(os.popen(cmd).read())

