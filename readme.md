#### flannel一键安装脚本
###### 下载脚本

```
git clone https://github.com/zcx5825585/flannel-init.git && cd flannel-init
```
###### 设置k8smaster地址 如192.168.0.81:8001
```
export MASTER_ADDRESS=192.168.0.81:8001
```
###### 运行一键安装脚本
```
chmod +x flannel.sh
./flannel.sh
```
