
# compact  

容器镜像压缩工具
Docker image compact tool  


容器名称：  

zcm-compact  

使用方法：  


1.sh zcm-compact.sh extract new_directory_name  

  请找一个有足够空间的目录，如“/zpaas/zcm/compact”作为专用的解压缩路径，    
  第一次使用时，将zcm-compact.sh放入其中。   
  每次要解压时，在此路径中创建一个新目录，如“20190912”，  
  将images.squashfs，restore_layers.sh放入新目录，   
  然后你可以执行命令来解压镜像。     

  例如，  
  sh zcm-compact.sh extract 20190912  

    /zpaas/zcm/compact/  
      ├────zcm-compact.sh    
      └────20190912    
            ├────images.squashfs    
            └────restore_layers.sh    


 2.sh zcm-compact.sh compact new_directory_name/filename.lst  
  
  请先将镜像拉到本地，编辑镜像名形成一个列表保存为文件，以“.lst”为后缀名，例如“201909.lst”。    
  找一个有足够空间的目录，比如“/zpaas/zcm/compact”，作为专用的解压缩路径，    
  第一次使用时，将zcm-compact.sh放入其中。      
  每次要压缩时，在这个目录下创建一个像“20190913”这样的新目录，并将列表文件放入新目录，   
  然后你可以执行命令来压缩镜像。   

  例如，  
  sh zcm-compact.sh compact 20190913/201909.lst  

   /zpaas/zcm/compact/  
      ├────zcm-compact.sh  
      └────20190913  
            └────201909.lst  
