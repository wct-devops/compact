import os
import sys
import json

UNFOLD_DIR = "unfold"
SHARED_DIR = os.path.join(UNFOLD_DIR, "shared" ) 

os.path.exists(UNFOLD_DIR) or os.makedirs(UNFOLD_DIR)
os.path.exists(SHARED_DIR) or os.makedirs(SHARED_DIR)

SHAID_EXISTS   = {}
RESTORE_LAYERS = {}

merge_res_list=[]

if len(os.sys.argv) > 1 :
    for line in open( os.sys.argv[1] ,'rt' ).readlines():
        line = line.replace('\n','')
        line = line.replace(' ','')
        if len(line) > 1 :
            SHAID_EXISTS[line] = 1 

for image_name in os.listdir(UNFOLD_DIR):
    each_image_home = os.path.join( UNFOLD_DIR, image_name )
    if image_name == 'shared':
        continue
    
    layer_list = []
    shaid_list = []
    image_size=0
    for file in os.listdir( each_image_home ):
        if file[-5:] == '.json' :
            if file == 'manifest.json':
                d = json.loads( open( os.path.join(each_image_home, file) ,'rt').read() )
                layer_list = d[0]["Layers"]
            else:
                d = json.loads( open( os.path.join(each_image_home, file) ,'rt').read() )
                shaid_list = d["rootfs"]["diff_ids"]
    for i in range(0, len(shaid_list)) :
        if ( os.path.islink( os.path.join( each_image_home, layer_list[i] ))) :
           continue
        if shaid_list[i] in SHAID_EXISTS :
           cmd = "cd " + each_image_home + "; > %s"%layer_list[i]
           print(cmd)
           print(os.popen( cmd ).read())
        else:
           layer_id = layer_list[i].split('/')[0]
           shaid = shaid_list[i]
           shared_shaid_path = os.path.join( SHARED_DIR, shaid)
           cmd = "cd %s; mv %s %s.tar"%( each_image_home, layer_list[i], os.path.join("..", "..", shared_shaid_path))
           print(cmd)
           ret=os.system(cmd)
           if ret != 0:
               print("Execute CMD [{}] Failed!".format(cmd))
               exit(1)
           # sum layer size
           du_cmd = "du -sm {}.tar".format(shared_shaid_path)
           try:
               du_res = os.popen(du_cmd).read().split()[0]
               layer_size=int(du_res)
           except Exception as err:
               layer_size=0
           image_size=image_size+layer_size
        
           restore_target = RESTORE_LAYERS.get( "%s.tar"%shared_shaid_path ) 
           if restore_target is None :
               restore_target = []
               RESTORE_LAYERS["%s.tar"%shared_shaid_path] = restore_target
           restore_target.append( os.path.join( each_image_home, layer_id, "layer.tar" ) )

    res_str = "{}: {}MB".format(image_name, image_size)
    merge_res_list.append(res_str)

restore_shell = open("restore_layers.sh","wt")
for layer_name in RESTORE_LAYERS.keys():
    restore_target = RESTORE_LAYERS[layer_name]    
    for i in range(0, len(restore_target)):
        if i == len(restore_target) - 1:
            restore_shell.write("mv %s %s\n"%(layer_name, restore_target[i]))
        else:
            restore_shell.write("cp %s %s\n"%(layer_name, restore_target[i]))
restore_shell.close()

merge_res_list=[line+"\n" for line in merge_res_list]
with open('summary/summary_compact_merge_size.txt','w') as f:
    f.writelines(merge_res_list)

for filename in os.listdir( SHARED_DIR ):
    if filename[-4:] == '.tar':
        shaid = filename[:-4]
        shared_shaid_path = os.path.join( SHARED_DIR, shaid)
        os.path.exists(shared_shaid_path) or os.makedirs(shared_shaid_path)
        tar_meta_file = os.path.join( SHARED_DIR , shaid + "_meta.json.gz")
        cmd = "./tar-split disasm --output %s %s.tar | tar -C %s -x && rm %s.tar"%( tar_meta_file, shared_shaid_path, shared_shaid_path , shared_shaid_path)
        print(cmd)
        print(os.popen(cmd).read()) 

cmd="mksquashfs unfold/ images.squashfs"
print(cmd)
print(os.popen( cmd ).read())

