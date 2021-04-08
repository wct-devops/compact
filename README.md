# zcm-compact v1.3
## 查看帮忙信息
查看zcm-compact.sh脚本的帮忙信息
```
sh zcm-compact.sh -h
sh zcm-compact.sh help
```
## 打包镜像
从指定的镜像列表文件中打包镜像，参考命令如下：
```
sh zcm-compact.sh compact myimage.lst
sh zcm-compact.sh compact mydir/myimage.lst
```
如果需要以远端机器shaid增量打包，参考命令如下：
```
sh zcm-compact.sh compact myimage.lst remote_aliyun.lst
sh zcm-compact.sh compact mydir/myimage.lst mydir/remote_aliyun.lst
```

## 解压镜像
将本脚本打包的镜像进行解压，参考命令如下：
```bash
sh zcm-compact.sh extract myimagedir/
```

## 清理镜像
清理当前机器上的历史镜像（默认同名镜像只保留一个，也可以单独指定保留个数），参考命令如下：
```bash
sh zcm-compact.sh clean ## 同名镜像保留1个
sh zcm-compact.sh clean 3  ## 同名镜像保留3个
```

## 修改镜像
将指定的镜像列表进行重命名，并推送到对应的镜像仓库中
```bash
sh zcm-compact.sh rename imagedir/myimage.lst imagedir/myharbor.cfg
```

## Support
 For support, bug reporting and feedback about the provided Tool, please open an [issue on Gitlab](http://gitlab.iwhalecloud.com/cloud/zcm-compact/issues)