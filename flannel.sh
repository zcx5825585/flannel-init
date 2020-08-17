#!/bin/bash
mkdir /usr/src/flannel
tar -xzvf flannel-v0.11.0-linux-amd64.tar.gz -C /usr/src/flannel
cp file/ /usr/src/flannel/ -r
cat <<EOF >/usr/src/flannel/nodeName
NODE_NAME=$HOSTNAME
MASTER_ADDRESS=$MASTER_ADDRESS
EOF
cp /usr/src/flannel/file/flanneld.service /etc/systemd/system/ 
cp /usr/src/flannel/file/kube-flannel /etc/ -r
systemctl daemon-reload 
systemctl enable flanneld 
systemctl start flanneld
cp /usr/src/flannel/file/docker.service /lib/systemd/system/ 
systemctl daemon-reload
systemctl restart docker
