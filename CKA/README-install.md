<img height='36pix' src='https://img.shields.io/badge/Kubernetes-v1.24.1-326CE5?style=for-the-badge&logo=kubernetes&logoColor=F5F5F5'> <img height='36pix' src='https://img.shields.io/badge/Ubuntu-22.04%20LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=F5F5F5'> 

[toc]

准备练习环境
====

参考： [Kubernetes 文档](https://kubernetes.io/zh/docs/) / [入门](https://kubernetes.io/zh/docs/setup/) / [生产环境](https://kubernetes.io/zh/docs/setup/production-environment/) / [使用部署工具安装 Kubernetes](https://kubernetes.io/zh/docs/setup/production-environment/tools/) /  [使用 kubeadm 引导集群](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/) / [安装 kubeadm](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
<hr>

## B. 准备开始

- 一台兼容的 Linux 主机。Kubernetes 项目为基于 Debian 和 Red Hat 的 Linux 发行版以及一些不提供包管理器的发行版提供通用的指令
- 每台机器 `2 GB` 或更多的 RAM （如果少于这个数字将会影响你应用的运行内存)
- `2 CPU 核`或更多
- 集群中的所有机器的网络彼此均能相互连接(公网和内网都可以)
- 节点之中`不可以有重复的`主机名、MAC 地址或 product_uuid。请参见[这里](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address)了解更多详细信息。
- 开启机器上的某些端口。请参见[这里](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports) 了解更多详细信息。
- 禁用交换分区。为了保证 kubelet 正常工作，你 **必须** `禁用交换分区`。

## U. 确保每个节点上 MAC 地址和 product_uuid 的唯一性 

- 你可以使用命令 `ip link` 或 `ifconfig -a` 来获取网络接口的 MAC 地址
- 可以使用 `sudo cat /sys/class/dmi/id/product_uuid` 命令对 product_uuid 校验

一般来讲，硬件设备会拥有唯一的地址，但是有些虚拟机的地址可能会重复。 Kubernetes 使用这些值来唯一确定集群中的节点。 如果这些值在每个节点上不唯一，可能会导致安装 [失败](https://github.com/kubernetes/kubeadm/issues/31)。
<hr>


## V. <img  height='36pix' src="https://www.vmware.com/content/dam/digitalmarketing/vmware/en/images/company/vmware-logo-grey.svg"> 虚拟机  

> <kbd>新建...</kbd> / <kbd>创建自定虚拟机</kbd> /
> ​		<kbd>Linux</kbd> / ==Ubuntu 64位==

- 设置过程

|  ID  |   『虚拟机』设置   |        建议配置        | 默认值  |     说明     |
| :--: | :--------: | :--------------------: | :-----: | :----------: |
|  1   |   处理器   |           -            |    2    |   最低要求   |
|  2   |    内存    |           -            | 4096 MB |   节约内存   |
|  3   |   显示器   | 取消复选`加速 3D 图形` |  复选   |   节约内存   |
|  4   | 网络适配器 |           -            |   nat   |    需上网    |
|  5   |    硬盘    |         `40`GB         |  20 GB  | 保证练习容量 |
|  6   |    选择固件类型  |         UEFI         |  传统 BIOS  | VMware Fusion 支持嵌套虚拟化 |

<img src="https://img-blog.csdnimg.cn/f7aa3c4646974cfb96d669b4c26c9f87.png">

- 设置结果

|  ID  | Your computer's name |    CPU 核    |      RAM       |   DISK    |   NIC   |
| :--: | :------------------: | :----------: | :------------: | :-------: | :-----: |
|  1   |     ==k8s-master==     | 4 或更多 | 8 GB或更多 | 40 GB | nat |
|  2   |    ==k8s-worker1==    |     同上     | 2 GB或更多 |   同上    |  同上   |
|  3   |    ==k8s-worker2==    |     同上     |      同上      |   同上    |  同上   |
<hr>

## I. 安装 [Ubuntu 22.04 LTS](https://mirror.nju.edu.cn/ubuntu-releases/20.04.4/ubuntu-20.04.4-live-server-amd64.iso)

1. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Willkommen! Bienvenue! Welcome! Welkom!</div>
   
    &nbsp;&nbsp;&nbsp;&nbsp;[ ==English== ]
    ![](https://i0.hdslb.com/bfs/album/a0338a7bde5eafa88d0825a2e2229bf2e4efdc20.png)
    
2. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Installer update available</div>

   &nbsp;[ ==Continue without updating== ]
   ![](https://i0.hdslb.com/bfs/album/12871e8aecd2311cfd73f9720326ad91330ad5c6.png)


3. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Keyboard configuration</div>
   
   <kbd>Done</kbd>
   ![](https://i0.hdslb.com/bfs/album/a45b2e7dfb535a8ce08af172250cf0a335649102.png)
   
4. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Choose type of install</div>
   
    (==X==)	Ubuntu Server (minimized)
    / <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/a98475163c0da9ab898dabc94e4cb020d0679f0a.png)
    
5. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Network connections</div>
   
    <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/21eebc9d8d07d2faec496fedf9d31914a4b4da25.png)
    
6. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Configure proxy</div>
   
    <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/f2e00aabb0aceb682e4ffcaf5b6b30490f9dbcd6.png)
    
7. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Configure Ubuntu archive mirror</div>
   
    Mirror address: http://mirror.nju.edu.cn/ubuntu
    / <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/82d5edd0c1af3f611fca5720a5f3ffde804ed55b.png)
    
8. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Guided storage configuration</div>
   
    <kbd>Done</kbd>
    
    ![](https://i0.hdslb.com/bfs/album/fa5c13572ff681c09ce0f7f9d821aebcdad4a9a8.png)
    
9. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Storage configuration</div>
   
   <kbd>Done</kbd>![](https://i0.hdslb.com/bfs/album/c66299ccb40b9c070fd09e9522fbbd17584b3b86.png)
   
   ![](https://i0.hdslb.com/bfs/album/4c343759631374bca1cb38bde53cb4a346d937a7.png)
   
10. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Profile setup</div>
    
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Your name: ==kiosk== 
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Your server 's name: ==k8s-master== 
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pick a username: ==kiosk== 
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Choose a password: ==ubuntu== 
    &nbsp;&nbsp;&nbsp;&nbsp;Confirm your password: ==ubuntu==
    &nbsp;&nbsp;&nbsp;&nbsp;/ <kbd>Done</kbd>
    
    ![](https://i0.hdslb.com/bfs/album/9479d4b026f145db15ef1db4f2cec210c49bef28.png)
    
11. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >SSH Setup</div>
    
    ​      [==X==] Install OpenSSH server
    ​      / <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/5d6583f6b95f3fdfe216d8edf9d6157b3ffe97da.png)

12. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Featured Server Snaps</div>
    
    <kbd>Done</kbd>
    ![](https://i0.hdslb.com/bfs/album/49664c2c6f651547714d3da7232400dce3dda183.png)

13. <div style="background: #D85E33; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Install complete!</div>
    
    :a: <kbd>Cancel update and reboot</kbd>
    
    ![](https://i0.hdslb.com/bfs/album/1a4335ccda8f1605d2a09132cd5014d23e13e9d5.png)
    
    :b: <kbd>Reboot Now</kbd>![](https://i0.hdslb.com/bfs/album/71441fc41a6b617291e669da73fb97e1e6b4ef17.png)

14. 建议（可选）

    关机后，做个快照

<hr>

## E. 执行脚本 ==k8s_init.sh==
> 如果系统安装时密码不是`ubuntu`，<br>请修改此脚本中变量`USER_PASS`为相应的值

**[kiosk@k8s-master|k8s-worker]**

```bash
$ /bin/bash -c \
    "$(curl -s https://vmcc.xyz:8443/k8s/k8s-init.sh)"
```

<hr>

## C. 确认环境正常

**[kiosk@k8s-master]**

```bash
$ kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler           `Healthy`  ok
controller-manager  `Healthy`  ok
etcd-0              `Healthy`  {"health":"true","reason":""}

$ kubectl get nodes
NAME          STATUS   ROLES                  AGE     VERSION
k8s-worker1  `Ready`  <none>                 4m4s    `v1.24.1`
k8s-worker2  `Ready`  <none>                 4m44s   `v1.24.1`
k8s-master   `Ready`  control-plane,master   13m     `v1.24.1`

$ kubectl -n kube-system get pod
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-555bc4b957-8ccgh   1/1     Running   0          27m
calico-node-5qqcq                          1/1     Running   0          9m29s
calico-node-7qclz                          1/1     Running   0          27m
calico-node-kcvt5                          1/1     Running   0          9m29s
coredns-74586cf9b6-69fn7                   1/1     Running   0          156m
coredns-74586cf9b6-8mgl9                   1/1     Running   0          156m
etcd-k8s-master                            1/1     Running   0          156m
kube-apiserver-k8s-master                  1/1     Running   0          156m
kube-controller-manager-k8s-master         1/1     Running   0          156m
kube-proxy-8j248                           1/1     Running   0          9m29s
kube-proxy-g7r55                           1/1     Running   0          9m29s
kube-proxy-rbdcp                           1/1     Running   0          156m
kube-scheduler-k8s-master                  1/1     Running   0          156m
```
