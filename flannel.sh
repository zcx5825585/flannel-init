#!/bin/bash
mkdir /usr/src/flannel
tar -xzvf flannel-v0.11.0-linux-amd64.tar.gz -C /usr/src/flannel

cat <<EOF >/usr/src/flannel/nodeName
NODE_NAME=$HOSTNAME
MASTER_ADDRESS=$MASTER_ADDRESS
EOF

cat <<EOF >/etc/systemd/system/flanneld.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/usr/src/flannel/nodeName
ExecStart=/usr/src/flannel/flanneld --kube-subnet-mgr --kube-api-url http://${MASTER_ADDRESS}
ExecStartPost=/usr/src/flannel/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF
cat <<EOF >/etc/kube-flannel/net-conf.json
{
  "Network": "10.244.0.0/16",
  "Backend": {
    "Type": "vxlan"
  }
}
EOF

systemctl daemon-reload 
systemctl enable flanneld 
systemctl start flanneld

cat <<EOF >/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
EnvironmentFile=/run/flannel/docker
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart docker
