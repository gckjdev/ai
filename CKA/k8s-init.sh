#!/bin/bash

# defaine var
export USER_PASS=ubuntu
LOG_FILE=/tmp/k8s-setup.log

# define function
function pad {
  echo -e " $(date +%H:%M) [I] \e[1;36m$(hostname)\e[0;39m - ${1}"
}
function LINE {
  STTY_SIZE=$(stty size)
  STTY_COLUMNS=$(echo $STTY_SIZE | cut -f2 -d" ")
  yes = 2>/dev/null | sed $STTY_COLUMNS'q' | tr -d '\n'
  printf "\n"
}
function separator {
    echo $(date "+%b %d %T") $(hostname) ============================================ >&4 2>&1
}

function check_env {
  if [[ "$(id -u)" -ne "1000" ]]; then
    echo -e '\e[1;31mERROR: \e[0;39mThis script must be run as \e[1;36m$(id -un 1000)\e[0;39m!'
    exit
  fi
}

function user_sudo {
    sudo tee /etc/sudoers.d/$USER >/dev/null <<EOF
$USER ALL=(ALL) NOPASSWD:ALL
EOF
}

function sources_list {
	# openssh-server, vim, sshpass, open-vm-tools
    MIRROR_URL=http://mirror.nju.edu.cn/ubuntu
    RELEASE_NAME=$(lsb_release -c | awk '{print $2}')
    while ps aux | grep -v grep | grep apt; do sleep 1s; done
    sudo tee /etc/apt/sources.list >/dev/null <<EOF
deb $MIRROR_URL $RELEASE_NAME main restricted universe multiverse
deb $MIRROR_URL $RELEASE_NAME-updates main restricted universe  multiverse
deb $MIRROR_URL $RELEASE_NAME-backports main restricted universe multiverse
deb $MIRROR_URL $RELEASE_NAME-security main restricted universe multiverse
EOF
    sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
    sudo apt -y update
	sudo apt install -y openssh-server \
      vim sshpass nfs-common \
      bash-completion netcat-openbsd \
      open-vm-tools
}

function set_ip_static {
    # 配置IP
    GW=$(ip route | awk '/default/ {print $3}')
    NIC=$(ip a | awk -F: '/UP/ {print $2}' | grep -v lo | grep -o en.*)
    IPM=$(ip a show $NIC | awk '/inet / {print $2}')
    sudo tee /etc/netplan/00-installer-config.yaml >/dev/null  <<EOF
network:
  ethernets:
    $NIC:
      dhcp4: false
      addresses: [$IPM]
      gateway4: $GW
      nameservers:
        addresses: [8.8.8.8]
  version: 2
EOF
    # dns
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo netplan apply

    IP=$(echo $IPM | sed 's_/.*__')
}

function find_sip {
    # find master ip
    SIPA=$(echo $IP | cut -d. -f4)
    SIPO=$SIPA
    until nc -w 1 $(echo $IP | cut -d. -f 1-3).$SIPA 6443; do
        if [ $SIPA -eq $(expr $SIPO - 3) ]; then
            SIPA=$(expr $SIPO + 3)
        else
            SIPA=$(expr $SIPA - 1)
        fi
        echo $SIPA
    done
    export SIP=$(echo $IP | cut -d. -f 1-3).$SIPA
}

function ssh_publickey {
    # USER
    if [ "$role" == "master" ]; then
        ssh-keygen -f ~/.ssh/id_rsa -N '' >/dev/null
        sshpass -p $USER_PASS ssh-copy-id $USER@localhost
    fi
    if [ "$role" == "worker" ]; then
        sshpass -p $USER_PASS scp -r $USER@${SIP}:~/.ssh .
    fi

    # root
    sudo cp -a /home/$USER/.ssh /root
    sudo chown -R root:root ~root
}

function add_hosts {
	# appending /etc/hosts
    sudo sed -i -e '/HostKeyC/{s_#_ _;s_ask_no_}' \
      -e '/HostKey/a\    UserKnownHostsFile /dev/null' \
      -e '/^Host/a\    LogLevel ERROR' /etc/ssh/ssh_config

    if [ "$role" == "master" ]; then
	    sudo tee /etc/hosts >/dev/null <<EOF
127.0.0.1 localhost

$IP $(hostname -s)
EOF
    fi
    
    if [ "$role" == "worker" ]; then
        sshpass -p $USER_PASS ssh $USER@${SIP} "
            cat <<EOF | sudo tee -a /etc/hosts
$IP $(hostname -s)
EOF"
        sudo sshpass -p $USER_PASS scp $USER@${SIP}:/etc/hosts /etc/hosts
    fi
}

function set_swap {
	# 为了保证 kubelet 正常工作，你必须禁用交换分区
    if grep -q swap /etc/fstab; then
        SWAPF=$(awk '/swap/ {print $1}' /etc/fstab)
	    sudo swapoff $SWAPF
	    sudo sed -i '/swap/d' /etc/fstab
	    sudo rm $SWAPF
    fi
}
function lv_extend {
    export LVN=$(sudo lvdisplay | awk '/Path/ {print $3}')
    sudo lvextend -l 100%PVS $LVN
    if sudo blkid $LVN | grep -q ext4; then
        sudo resize2fs $LVN
    fi
    df -h /
}

function set_iptables {
	## 确保 br_netfilter 模块被加载
    sudo apt -y install bridge-utils
    sudo modprobe br_netfilter
:<<EOF
    $ lsmod | grep br
    br_netfilter           28672  0
    bridge                176128  1 br_netfilter
    $ sudo sysctl -a | grep bridge
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
EOF
    sudo tee /etc/sysctl.d/k8s.conf >/dev/null <<EOF
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
EOF
    sudo sysctl -p /etc/sysctl.d/k8s.conf

}

function install_runtime_docker {
    # daemon.json
    sudo mkdir -p /etc/docker
	sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "10"
  },
  "registry-mirrors": ["https://ktjk1d0g.mirror.aliyuncs.com"]
}
EOF

    # 安装 runtime
    sudo apt -y install docker.io
    sudo systemctl enable --now docker
}

function install_cri-dockerd {
    # cri-dockerd
    PKG_NAME=cri-dockerd-0.2.5.amd64.tgz
    ## https://github.com/Mirantis/cri-dockerd/
    PKG_URL=https://vmcc.xyz:8443/k8s/cri-docker
    curl -# $PKG_URL/$PKG_NAME -o $PKG_NAME
    tar -xf $PKG_NAME
    sudo cp cri-dockerd/cri-dockerd /usr/bin/

    # cri-docker.service
    ## https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
    sudo curl -s $PKG_URL/cri-docker.service \
      -o /usr/lib/systemd/system/cri-docker.service
    sudo sed -i '/ExecStart/s+$+ --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.8+' /usr/lib/systemd/system/cri-docker.service

    # cri-docker.socket
    ## https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
    sudo curl -s $PKG_URL/cri-docker.socket \
      -o /usr/lib/systemd/system/cri-docker.socket

    # 启动 cri-dockerd
    sudo systemctl daemon-reload
    sudo systemctl enable --now cri-docker

    # crictl 配置文件
    sudo tee /etc/crictl.yaml >/dev/null <<EOF
runtime-endpoint: unix:///var/run/cri-dockerd.sock
image-endpoint: unix:///var/run/cri-dockerd.sock
timeout: 10
debug: false
pull-image-on-create: true
EOF
}

function install_runtime_containerd {
    # containerd
    sudo apt install -y containerd
    sudo mkdir /etc/containerd
    containerd config default | \
        sudo tee /etc/containerd/config.toml >/dev/null
    sudo sed -i \
        -e '/sandbox_image/s?k8s.gcr.io?registry.aliyuncs.com/google_containers?' \
        -e '/SystemdCgroup/s?false?true?' \
        -e '/registry.mirrors/a\        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]' \
        -e '/registry.mirrors/a\          endpoint = ["https://ktjk1d0g.mirror.aliyuncs.com"]' /etc/containerd/config.toml
    sudo systemctl restart containerd

    # crictl 配置文件
    sudo tee /etc/crictl.yaml >/dev/null <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
pull-image-on-create: true
EOF

    # k8s surport
    sudo sed -i '/ExecStart=\//s|$| --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --cgroup-driver=systemd|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    sudo systemctl daemon-reload
    sudo systemctl restart kubelet
}

function cri-tools-install {
    # 测试工具
    ## https://github.com/kubernetes-sigs/cri-tools
    TAR_FILE=crictl-v1.24.2-linux-amd64.tar.gz
    ## https://github.com/Mirantis/cri-dockerd/
    PKG_URL=https://vmcc.xyz:8443/k8s/
    curl -# $PKG_URL/$TAR_FILE -o $TAR_FILE
    tar -xf $TAR_FILE
    sudo cp crictl /usr/bin/
}

function install_kube_tools {
	# 安装 kubeadm、kubelet 和 kubectl
	## 1. 更新 apt 包索引并安装使用 Kubernetes apt 仓库所需要的包
	sudo apt -y install apt-transport-https ca-certificates curl
	## 2. 下载 Google Cloud 公开签名秘钥
	curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
	## 3. 添加 Kubernetes apt 仓库
    ## https://packages.cloud.google.com/apt/doc/apt-key.gpg
    MIRROR_URL=https://mirror.nju.edu.cn/kubernetes/apt/
	sudo tee /etc/apt/sources.list.d/kubernetes.list \
      >/dev/null <<EOF
deb $MIRROR_URL kubernetes-xenial main
EOF
	## 4. 更新 apt 包索引，安装 kubelet、kubeadm 和 kubectl，并锁定其版本
    sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
	sudo apt update -y
	sudo apt-cache madison kubelet | grep 1.24
	# 取考试版本 1.24.1-00
    KV=1.24.1-00
    # KV=$(sudo apt-cache madison kubelet | grep $(curl -s https://training.linuxfoundation.cn/certificates/1 | grep -o 软件版本.*[0-9]\< | egrep -o '\.|[0-9]' | sed -e ':a;N;$!ba;s/\n//g') | awk '/\.1/ {print $3}')
    # 安装考试版本
    sudo apt install -y kubelet=${KV} kubeadm=${KV} kubectl=${KV}
    sudo apt-mark hold kubelet kubeadm kubectl
}

function kubeadm-cmd {
    # 说明：
    #    没有科学上网
    #    需使用 registry.aliyuncs.com/google_containers

    # 方法A，使用国内镜像仓库
:<<EOF
    $ sudo kubeadm init \
      --apiserver-advertise-address=$IP \
      --image-repository registry.aliyuncs.com/google_containers
    $ sudo kubeadm reset
EOF
}

function kubeadm-config {    
    # 方法B
    # 配置 kubeadm、kubelet 和 kubectl
	sudo kubeadm config print init-defaults > kubeadm-config.yaml
}

function kubeadm-config-docker {
    sudo sed -i \
        -e "/advertiseAddress/s?:.*?: $(echo $IP | sed 's_/.*__')?" \
        -e "/name/s?:.*?: $(hostname -s)?" \
        -e "/clusterName/s?:.*?: ck8s?" \
        -e "/imageRepository/s?:.*?: registry.aliyuncs.com/google_containers?" \
        -e "/criSocket/s+containerd/containerd+cri-dockerd+" kubeadm-config.yaml
}

function kubeadm-config-containerd {
    sudo sed -i \
        -e "/advertiseAddress/s?:.*?: $(echo $IP | sed 's_/.*__')?" \
        -e "/name/s?:.*?: $(hostname -s)?" \
        -e "/clusterName/s?:.*?: ck8s?" \
        -e "/imageRepository/s?:.*?: registry.aliyuncs.com/google_containers?" kubeadm-config.yaml
}

function kubeadm_init {
    sudo kubeadm init --config kubeadm-config.yaml
:<<EOF
...输出省略...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.147.128:6443 --token abcdef.0123456789abcdef \
	--discovery-token-ca-cert-hash sha256:c4781194de65ebb47984fc5e7e64d4897875410825ce4d18df81da1a298afa1f
EOF

    # 根据 init 执行的后的提示操作
    ## user
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ## root
    sudo tee -a ~root/.bashrc >/dev/null <<EOF
export KUBECONFIG=/etc/kubernetes/admin.conf
EOF

	# 在所有节点设置 kubelet 开机自启动
	sudo systemctl enable --now kubelet
}

function kube_network {
    # 部署网络插件
    
    ## 方法A：calico
    ## SEE ALSO https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises
	kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

    ## 方法B：flannel
    ## https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

function kube_join_docker {
    # 添加节点
:<<EOF
    # KTK=$(sshpass -p $USER_PASS ssh $USER@${SIP} \
        sudo kubeadm token create)
    # KHEX=$(sshpass -p $USER_PASS ssh $USER@${SIP} \
        openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
        | openssl rsa -pubin -outform der 2>/dev/null \
        | openssl dgst -sha256 -hex \
        | sed 's/^.* //')
    # sudo kubeadm join ${SIP}:6443 \
        --token ${KTK} \
        --discovery-token-ca-cert-hash sha256:${KHEX}
EOF
    JOIN_CMD=$(sshpass -p $USER_PASS ssh $USER@${SIP} \
        "kubeadm token create --print-join-command")
    JOIN_ARG="--cri-socket unix://var/run/cri-dockerd.sock"
    sudo $JOIN_CMD $JOIN_ARG
}

function kube_join_containerd {
    # 添加节点
    JOIN_CMD=$(sshpass -p $USER_PASS ssh $USER@${SIP} \
        "kubeadm token create --print-join-command")
    sudo $JOIN_CMD
}

function kube_bash_completion {
    # Installing bash completion on Linux
    ## If bash-completion is not installed on Linux, install the 'bash-completion' package
    ## via your distribution's package manager.

    ## Load the kubectl completion code for bash into the current shell
    source <(kubectl completion bash)
    
    ## Write bash completion code to a file and source it from .bash_profile
    mkdir ~/.kube
    kubectl completion bash > ~/.kube/completion.bash.inc
    printf "
# Kubectl shell completion
source '$HOME/.kube/completion.bash.inc'
" >> $HOME/.bashrc
    source $HOME/.bashrc

    ## root
    sudo mkdir /root/.kube
    kubectl completion bash | \
        sudo tee /root/.kube/completion.bash.inc
    sudo tee -a /root/.bashrc >/dev/null <<EOF
# Kubectl shell completion
source '/root/.kube/completion.bash.inc'
EOF
}

function alias_k {
    ## USER
    if ! grep -q alias.*k= ~/.bashrc; then
        printf "
    alias k='kubectl'
    complete -F __start_kubectl k
    " >> $HOME/.bashrc
        source $HOME/.bashrc
    fi
    
    ## root
    if ! sudo grep -q alias.*k= /root/.bashrc; then
        cat <<EOF | sudo tee -a /root/.bashrc
alias k='kubectl'
complete -F __start_kubectl k
EOF
    fi
}

function select_role {
    echo "Please select your ROLE: "
    select role in master worker Quit; do
        case $role in
            master|worker)
                echo -e "Your choice is $role" 
                ;;
            Quit)
                exit
                ;;
            *)
                echo "You didn't choose anything"
                ;;
        esac
        break
    done
}

# Main Area
check_env
exec 4>${LOG_FILE}
LINE
echo -e "\n
   Please wait a moment, about \e[1;37m6\e[0;38m minutes. 
   If you see more details, please open a new terminal, and type

    \e[1;37mtail -f ${LOG_FILE}\e[0;39m
"
LINE
echo
if hostname -s | grep -q master; then
    role=master
elif hostname -s | grep -q worker; then
    role=worker
else
    select_role
fi
echo
    user_sudo >&4 2>&1
separator; pad "Set $USER sudo"
    lv_extend >&4 2>&1
separator; pad "Installing ssh vim sshpass nfs"
    sources_list >&4 2>&1
separator; pad "set static ip address"
    set_ip_static >&4 2>&1
if [ "$role" == "worker" ]; then
    separator; pad "find master(SIP)..."
        find_sip >&4 2>&1
fi
separator; pad "Append /etc/hosts"
    add_hosts >&4 2>&1
separator; pad "ssh publickey"
    ssh_publickey >&4 2>&1
separator; pad "Disable swap"
    set_swap
separator; pad "Letting iptables see bridged traffic"
    set_iptables >&4 2>&1

# docker        master, worker1
# containerd    worker2
if hostname | grep -q worker2; then
    separator; pad "Installing runtime (containerd)"
    install_runtime_containerd >&4 2>&1
else
    separator; pad "Installing runtime (docker)"
    install_runtime_docker >&4 2>&1
    separator; pad "Installing cri-dockerd"
    install_cri-dockerd >&4 2>&1
fi

separator; pad "Installing cri-tools"
    cri-tools-install >&4 2>&1
separator; pad "Installing kubeadm, kubelet and kubectl"
    install_kube_tools >&4 2>&1
separator; pad "kube bash completion"
    kube_bash_completion >&4 2>&1
separator; pad "alias k=kubectl"
    alias_k >&4 2>&1

if [ "$role" == "master" ]; then
    separator; pad "kube init"
        kubeadm-config >&4 2>&1
        kubeadm-config-docker >&4 2>&1
       #kubeadm-config-containerd >&4 2>&1
        kubeadm_init >&4 2>&1
    separator; pad "kube network"
        kube_network >&4 2>&1
    echo
    echo "[verify] $ kubectl get componentstatuses"
    echo "         $ kubectl get nodes"
    echo "         $ kubectl -n kube-system get pod"
    echo
fi

if [ "$role" == "worker" ]; then
    separator; pad "kubeadm join"

    # echo server ok
    until sshpass -p $USER_PASS ssh $USER@${SIP} \
        "grep kubeadm.*join.*--token $LOG_FILE &>/dev/null"; do
        sleep 1
    done

    # join
    if hostname | grep -q worker1; then
        kube_join_docker >&4 2>&1
    else
        kube_join_containerd >&4 2>&1
    fi
fi

exec bash
echo