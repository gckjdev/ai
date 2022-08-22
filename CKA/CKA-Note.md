

[TOC]

# 1. 容器技术概述

## 1.1 容器技术基础

### Lab1. 创建虚拟机

> https://www.vmware.com/cn.html

### Lab2. 安装 ubuntu

> https://mirror.nju.edu.cn/ubuntu-releases/22.04/ubuntu-22.04.1-live-server-amd64.iso
>
> https://suzhen99.coding.net/public/os/k8s/git/files

### Lab3. 安装 docker

|      | 参考URL                                                      |              |          说明          |
| :--: | ------------------------------------------------------------ | :----------: | :--------------------: |
|  1   | https://docs.docker.com/engine/install/ubuntu/               |     国外     |                        |
|  2   | https://developer.aliyun.com/mirror/docker-ce?spm=a2c6h.13651102.0.0.3e221b11NzQkC4 |     国内     |                        |
|  3   | https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors  | 镜像仓库加速 | 先注册一个帐号，并登陆 |
|      | https://mirror.nju.edu.cn/help/docker-ce                     |              |         README         |

```bash
step 1: 安装必要的一些系统工具
$ sudo apt-get update
$ sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

step 2: 安装GPG证书
$ curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

Step 3: 写入软件源信息
$ sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

Step 4.1: 更新
$ sudo apt-get -y update

查找Docker-CE的版本
$ apt-cache madison docker-ce

Step 4.2: 安装Docker-CE
$ sudo apt-get -y install docker-ce=5:19.03.15~3-0~ubuntu-focal
```

```bash
配置镜像加速器

创建文件夹
$ sudo mkdir -p /etc/docker

创建文件
$ sudo tee /etc/docker/daemon.json <<-'EOF'
{
   "registry-mirrors": ["https://ktjk1d0g.mirror.aliyuncs.com"]
}
EOF

重新载入
$ sudo systemctl daemon-reload

重启服务
$ sudo systemctl restart docker

验证服务状态
$ systemctl status docker
```

## 1.2 容器基础操作

### Lab4. 运行一个容器

> docker run, images, ps

```bash
切换身份
# sudo -i

运行一个容器，会自动拉取镜像
# docker run -p 8080:80 -d httpd
Unable to find image 'httpd:latest' locally
latest: Pulling from library/httpd
a2abf6c4d29d: Pull complete 
dcc4698797c8: Pull complete 
41c22baa66ec: Pull complete 
67283bbdd4a0: Pull complete 
d982c879c57e: Pull complete 
Digest: sha256:0954cc1af252d824860b2c5dc0a10720af2b7a3d3435581ca788dff8480c7b32
Status: Downloaded newer image for httpd:latest
9ccfdb9313de4b7743f3f49cd7f99e8ae2fbaaa77d826af630bf12c449febdcd

查看本地镜像
# docker images 
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
`httpd`        latest    dabbfbe0c57b   2 months ago   144MB

查看正在运行的容器（容器就是一个进程）
# docker ps
CONTAINER ID   IMAGE     COMMAND              CREATED         STATUS         PORTS                  NAMES
9ccfdb9313de   httpd     "httpd-foreground"   2 minutes ago   `Up` 2 minutes   0.0.0.0:8080->80/tcp   `dazzling_bohr`

验证容器可以使用端口8080访问
# curl localhost:8080
<html><body><h1>It works!</h1></body></html>
```

### Lab5. 容器生命周期管理

> docker start, stop

```bash
停止容器
# docker stop dazzling_bohr 
dazzling_bohr

查看正在运行的容器
# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

查看所有的容器（包括已停止）
# docker ps -a
CONTAINER ID   IMAGE     COMMAND              CREATED          STATUS                          PORTS     NAMES
9ccfdb9313de   httpd     "httpd-foreground"   10 minutes ago   `Exited` (0) About a minute ago             dazzling_bohr

启动容器
# docker start dazzling_bohr 
dazzling_bohr

查看正在运行的容器
# docker ps
CONTAINER ID   IMAGE     COMMAND              CREATED          STATUS         PORTS                  NAMES
9ccfdb9313de   httpd     "httpd-foreground"   12 minutes ago   `Up` 4 seconds   0.0.0.0:8080->80/tcp   dazzling_bohr
```

### Lab6. 进入容器的方法1

> docker attach

```bash
A场景，容器运行后直接退出。容器当中没有服务或正在运行的程序
# docker run -d centos 
# docker ps

B场景，容器一直运行不会退。快捷键不可用
# docker run --name a1 -d centos \
  /bin/bash -c "while true; do sleep 1; echo haha; done"
# docker ps

# docker attach a1 
<Ctrl-C>						不可用
<Ctrl-p><Ctrl-q>		不可用
只能关闭当前终端或结束当前进程

C场景，-it interactive交互模式，tty终端。可使用快捷键
# docker run --name a2 -it -d centos \
	/bin/bash -c "while true; do sleep 1; echo haha; done"
# docker ps
# docker attach a2
<Ctrl-p><Ctrl-q>		可用。可正常退出容器
```

### Lab7.进入容器的方法2

> docker exec

```bash
# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
903e1389d91d   centos    "/bin/bash -c 'while…"   12 minutes ago   Up 12 minutes             confident_rhodes
`5783569707c0`   centos    "/bin/bash -c 'while…"   14 minutes ago   Up 14 minutes             funny_napier

# docker exec -it <Tab><Tab>
confident_rhodes  funny_napier      

进入容器
# docker exec -it funny_napier /bin/bash
[root@5783569707c0 /]# ls
bin  etc   lib	  lost+found  mnt  proc  run   srv  tmp  var
dev  home  lib64  media       opt  root  sbin  sys  usr
[root@5783569707c0 /]# pwd
/
[root@5783569707c0 /]# cat /etc/redhat-release 
CentOS Linux release 8.4.2105
[root@5783569707c0 /]# exit

#
```



# 2. 容器镜像

##  2.1 容器镜像结构

### Lab8. 理解镜像结构

```bash
查看本地镜像
# docker images

从镜像仓库拉取镜像 ubuntu
# docker pull ubuntu
# docker images

查看镜像相关信息
# docker image inspect ubuntu:latest 

使用镜像运行容器
# docker run -itd ubuntu
# docker ps

查看容器根目录
# docker exec -it pensive_mcnulty ls /
查看本地根目录
# ls /
```

## 2.2 构建容器镜像

### Lab9. docker-commit 命令

```bash
运行一个容器。`--privileged`和`/sbin/init`，他们两个的作用是为了给`systemctl`使用
# docker run -itd --privileged centos /sbin/init
b8216e5e3f5a4e4f5ab778d4b2b4dde3b99866d983ad94c0d43454ffd99be9b3
容器状态
# docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
`b8216e5e3f5a`   centos    "/sbin/init"   4 seconds ago   Up 3 seconds             sleepy_pascal

进入你的容器
# docker exec -it b /bin/bash
安装软件，没成功
[root@b8216e5e3f5a /]# yum -y install httpd
Failed to set locale, defaulting to C.UTF-8
CentOS Linux 8 - AppStream                    39  B/s |  38  B     00:00    
Error: Failed to download metadata for repo 'appstream': Cannot prepare internal mirrorlist: No URLs in mirrorlist

删除已有软件仓库
参考：https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b119puefY
[root@b8216e5e3f5a /]# rm /etc/yum.repos.d/CentOS-Linux-*.repo -f

确认容器中存在哪个命令
[root@b8216e5e3f5a /]# whereis curl
curl: `/usr/bin/curl`
[root@b8216e5e3f5a /]# whereis wget
wget:

[root@b8216e5e3f5a /]# curl -so /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
 
确认仓库
[root@b8216e5e3f5a /]# yum repolist
Failed to set locale, defaulting to C.UTF-8
repo id            repo name
AppStream          CentOS-8.5.2111 - AppStream - mirrors.aliyun.com
base               CentOS-8.5.2111 - Base - mirrors.aliyun.com
extras             CentOS-8.5.2111 - Extras - mirrors.aliyun.com

安装软件
[root@b8216e5e3f5a /]# yum -y install httpd
...输出省略...
Complete!

生成索引页
[root@b8216e5e3f5a /]# echo haha > /var/www/html/index.html

设置服务开机自启，立即启动
[root@b8216e5e3f5a /]# systemctl enable --now httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.

测试web站点
[root@b8216e5e3f5a /]# curl localhost
haha

退出容器
[root@b8216e5e3f5a /]# exit

# docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED         STATUS         PORTS     NAMES
b8216e5e3f5a   centos    "/sbin/init"   6 minutes ago   Up 6 minutes             `sleepy_pascal`
# docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
httpd        latest    dabbfbe0c57b   2 months ago   144MB
ubuntu       latest    ba6acccedd29   4 months ago   72.8MB
centos       latest    5d0da3dc9764   5 months ago   231MB

创建新镜像
# docker commit sleepy_pascal test1
sha256:f46b9612f5beb0a4233ded79399204057f0f54ac44577d74920dc38a794b998d

# docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
`test1`        latest    f46b9612f5be   41 seconds ago   280MB
httpd        latest    dabbfbe0c57b   2 months ago     144MB
ubuntu       latest    ba6acccedd29   4 months ago     72.8MB
centos       latest    5d0da3dc9764   5 months ago     231MB

使用镜像test1，创建新的容器
# docker run -itd --privileged test1 /sbin/init
5b05167447e2743030f528e0d2dfb16cfc7d0b792a49651b583faf5e69c59561
# docker ps
CONTAINER ID   IMAGE     COMMAND        CREATED          STATUS          PORTS     NAMES
5b05167447e2   test1     "/sbin/init"   4 seconds ago    Up 3 seconds              sweet_kalam
b8216e5e3f5a   centos    "/sbin/init"   15 minutes ago   Up 15 minutes             sleepy_pascal
# docker exec -it 5 /bin/bash
[root@5b05167447e2 /]# rpm -q httpd
httpd-2.4.37-43.module_el8.5.0+1022+b541f3b1.x86_64
[root@5b05167447e2 /]# cat /var/www/html/index.html 
haha
[root@5b05167447e2 /]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor pr>
   Active: `active (running)` ...输出省略...
[root@5b05167447e2 /]# curl localhost
haha
[root@5b05167447e2 /]# exit

# docker history test1:latest 
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
`f46b9612f5be   12 minutes ago   /sbin/init                                      48.5MB`   
5d0da3dc9764   5 months ago     /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B        
<missing>      5 months ago     /bin/sh -c #(nop)  LABEL org.label-schema.sc…   0B        
<missing>      5 months ago     /bin/sh -c #(nop) ADD file:805cb5e15fb6e0bb0…   231MB     

# docker history centos:latest 
IMAGE          CREATED        CREATED BY                                      SIZE      COMMENT
5d0da3dc9764   5 months ago   /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B        
<missing>      5 months ago   /bin/sh -c #(nop)  LABEL org.label-schema.sc…   0B        
<missing>      5 months ago   /bin/sh -c #(nop) ADD file:805cb5e15fb6e0bb0…   231MB
```

### Lab10. dockfile 示例

```bash
$ sudo -i

创建文件夹
# mkdir df

切换目录
# cd df
查看当前工作目录
# pwd

生成文件 index.html
# echo haha > index.html
# ls

# vim dockerfile
```

```dockerfile
FROM httpd
COPY index.html /
RUN echo haha
```

```bash
通过 dockerfile 文件，建立 image
# docker build -t test2 .
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM httpd
 ---> a8ea074f4566
Step 2/3 : COPY index.html /
 ---> Using cache
 ---> e7056f1a4768
Step 3/3 : RUN echo haha
 ---> Running in bc67e25c5eb1
haha
Removing intermediate container bc67e25c5eb1
 ---> 55bba83d97fb
Successfully built 55bba83d97fb
Successfully tagged test2:latest

确认
# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
test2        latest    86965f4efffe   3 minutes ago   144MB
httpd        latest    dabbfbe0c57b   2 months ago    144MB
...输出省略...
```

### Lab11. dockfile 缓存特性

```bash
# vim dockerfile
```

```dockerfile
FROM httpd
COPY index.html /
RUN echo haha
MAINTAINER adder99@163.com
```

```bash
注意输出，层存在有缓存
# docker build -t test3 .
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM httpd
 ---> a8ea074f4566
Step 2/4 : COPY index.html /
 ---> `Using cache`
 ---> e7056f1a4768
Step 3/4 : RUN echo haha
 ---> `Using cache`
 ---> 55bba83d97fb
Step 4/4 : MAINTAINER alex@163.com
 ---> Running in f1b964adca56
Removing intermediate container f1b964adca56
 ---> f89944ec89c8
Successfully built f89944ec89c8
Successfully tagged test3:latest
```

```bash
更改指令顺序
# vim dockerfile
```

```dockerfile
FROM httpd
MAINTAINER adder99@163.com
COPY index.html /
RUN echo haha
```

```bash
注意输出，层变了没有缓存
# docker build -t test3 .
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM httpd
 ---> a8ea074f4566
Step 2/4 : MAINTAINER alex@163.com
 ---> Running in 19dbfc6564bb
Removing intermediate container 19dbfc6564bb
 ---> f09bc419e24b
Step 3/4 : COPY index.html /
 ---> 814027f1d794
Step 4/4 : RUN echo haha
 ---> Running in 50c44db04f7e
haha
Removing intermediate container 50c44db04f7e
 ---> 7bffb633acc0
Successfully built 7bffb633acc0
Successfully tagged test3:latest
```

### Lab12. docker tag

```bash
查看本地镜像
# docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
`httpd`        latest    dabbfbe0c57b   2 months ago   144MB
...输出省略...

查看镜像信息
# docker image inspect httpd | grep -i version
                "HTTPD_VERSION=2.4.52",
        "DockerVersion": "20.10.7",
                "HTTPD_VERSION=2.4.52",

给镜像打个新标签
# docker tag httpd httpd:v8.6

确认。ID相同，TAG不同，SIZE大小相同。它就是一个镜像
# docker images
REPOSITORY    TAG        IMAGE ID         CREATED        SIZE
httpd        `latest`    `dabbfbe0c57b`   2 months ago   144MB
httpd        `v8.6`      `dabbfbe0c57b`   2 months ago   144MB
...输出省略...
```

### Lab13. 搭建私有registry仓库

> - https://hub.docker.com
> - https://quay.io

```bash
创建文件夹
# mkdir /root/myregistry

运行容器
# docker run -d -p 1000:5000 -v /root/myregistry:/var/lib/registry registry
49ff98a0632a3526ba3ffcbab96d259375ac5c5c89a62818414ea0f17dd3d087
# docker ps
CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS          PORTS                    NAMES
49ff98a0632a   registry   "/entrypoint.sh /etc…"   24 seconds ago   Up 23 seconds   0.0.0.0:1000->5000/tcp   dazzling_euclid

检查容器
# docker inspect dazzling_euclid
...输出省略...
        "HostConfig": {
            "Binds": [
                "/root/myregistry:/var/lib/registry"
            ],
...输出省略...
            "PortBindings": {
                "5000/tcp": [
                    {
                        "HostIp": "",
                        "HostPort": "1000"
                    }
...输出省略...

确认监听端口
# ss -antup | grep 1000
tcp   LISTEN 0       4096                        *:1000                 *:*      users:(("docker-proxy",pid=4124,fd=4))

查看本地镜像
# docker images
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
httpd        v8.6      dabbfbe0c57b   2 months ago   144MB
...输出省略...

更改标签
# docker tag httpd:v8.6 192.168.73.137:1000/httpd:v8.6

上传到私有仓库，不成功
# docker push 192.168.73.137:1000/httpd:v8.6
The push refers to repository [192.168.73.137:1000/httpd]
Get https://192.168.73.137:1000/v2/: http: server gave HTTP response to HTTPS client

上一条命令的返回值是非0，都是不成功
# echo $?
1

添加"insecure-registries",注意第2行结尾的逗号
# vim /etc/docker/daemon.json
```

```json
{
  "registry-mirrors": ["https://ktjk1d0g.mirror.aliyuncs.com"],
  "insecure-registries": ["192.168.73.137:1000"]
}
```

```bash
# systemctl daemon-reload
# systemctl restart docker

服务重启后，容器默认不会启动
# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

查找容器名称
# docker ps -a
CONTAINER ID   IMAGE      COMMAND                  CREATED         STATUS                      PORTS     NAMES
49ff98a0632a   registry   "/entrypoint.sh /etc…"   6 minutes ago   Exited (2) 19 seconds ago             dazzling_euclid

启动容器
# docker start dazzling_euclid
dazzling_euclid

确定端口存在，即容器启动成功
# ss -antup | grep 1000
tcp   LISTEN 0       4096                        *:1000                 *:*      users:(("docker-proxy",pid=4613,fd=4))

再次推送镜像到私有镜像仓库，成功
# docker push 192.168.73.137:1000/httpd:v8.6
The push refers to repository [192.168.73.137:1000/httpd]
deefaa620a71: Pushed
9cff3206f9a6: Pushed
15e4bf5d0804: Pushed
1da636a1aa95: Pushed
2edcec3590a4: Pushed
v8.6: digest: sha256:57c1e4ff150e2782a25c8cebb80b574f81f06b74944caf972f27e21b76074194 size: 1365

确认镜像目录分层
# ls -R /root/myregistry/
```



# 3. 容器网络

## 3.1 容器网络

```bash
列出当前容器网络
# docker network ls
```

|      |       none       |         host          |                     bridge                     |
| :--: | :--------------: | :-------------------: | :--------------------------------------------: |
| NIC  | container / `lo` | container == physical | container / eth0-net1<br>container / eth1-net2 |
|  IP  |    127.0.0.1     | 192.168.73.137/物理机 |           172.18.0.2<br>172.10.10.3            |



### Lab14. none 网络

```bash
查看none网络配置
# docker network inspect none

查手册
# man docker run
/--network	搜索--network
<n>					Next下一个
<N>					Next上一个
<q>					退出手册

指定网络类型，运行容器
# docker run -itd --network none centos
f71cdaf893b0eb88a5010bd3d2acd356f08a33ab855cfd5a25c81acfe0f18374

# docker inspect f7
...输出省略...
            "Networks": {
                "none": {
                    "IPAMConfig": null,
...输出省略...

进入容器，查看网络配置（只有lo）
# docker exec -it f /bin/bash
[root@f71cdaf893b0 /]# ip a
1: `lo`: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
       
[root@f71cdaf893b0 /]# <Ctrl-D>
```

### Lab15. host 网络

```bash
# docker run -itd --network host --name h1 centos
19eca6316c274bf5127145ca6d6ea278e707eaa43c329569c3af01c2ced1971a
# docker run -itd --network host --name h2 centos
627e0a8e8e39490dc1df702fe6503de03ad8752dc6371054fa15d48d0447dd5a

# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
627e0a8e8e39   centos    "/bin/bash"   3 seconds ago   Up 3 seconds             h2
19eca6316c27   centos    "/bin/bash"   7 seconds ago   Up 7 seconds             h1
...输出省略...

确认本机网络
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:bf:e4:a0 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.73.137/24 brd 192.168.73.255 scope global dynamic noprefixroute ens33
       valid_lft 1180sec preferred_lft 1180sec
    inet6 fe80::ecfb:a225:eb42:6279/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:17:05:e2:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever

进入容器h1后，查看网络
# docker exec -it h1 /bin/bash
[root@kiosk-virtual-machine /]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:bf:e4:a0 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.73.137/24 brd 192.168.73.255 scope global dynamic noprefixroute ens33
       valid_lft 1154sec preferred_lft 1154sec
    inet6 fe80::ecfb:a225:eb42:6279/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:17:05:e2:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
[root@kiosk-virtual-machine /]# exit

进入容器h2后，查看网络
# docker exec -it h2 /bin/bash
[root@kiosk-virtual-machine /]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:bf:e4:a0 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.73.137/24 brd 192.168.73.255 scope global dynamic noprefixroute ens33
       valid_lft 1133sec preferred_lft 1133sec
    inet6 fe80::ecfb:a225:eb42:6279/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:17:05:e2:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
[root@kiosk-virtual-machine /]# exit
```

### Lab16. Bridge 网络

```bash
查看所有网卡，包含docker0
# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:bf:e4:a0 brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.73.137/24 brd 192.168.73.255 scope global dynamic noprefixroute ens33
       valid_lft 1175sec preferred_lft 1175sec
    inet6 fe80::ecfb:a225:eb42:6279/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: `docker0`: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:17:05:e2:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever

默认未安装
# ifconfig

Command 'ifconfig' not found, but can be installed with:

apt install net-tools

按提示安装
# apt install net-tools
...输出省略...

# ifconfig
`docker0`: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:17:05:e2:03  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.73.137  netmask 255.255.255.0  broadcast 192.168.73.255
        inet6 fe80::ecfb:a225:eb42:6279  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:bf:e4:a0  txqueuelen 1000  (Ethernet)
        RX packets 3169  bytes 679722 (679.7 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1985  bytes 242632 (242.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 544  bytes 50523 (50.5 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 544  bytes 50523 (50.5 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# ifconfig docker0
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:17:05:e2:03  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# docker network inspect bridge
...输出省略...
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
...输出省略...

启动容器后，<Ctrl-C>终止
# docker run -it --name httpd1 httpd
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message
[Tue Mar 08 14:37:18.605673 2022] [mpm_event:notice] [pid 1:tid 140469840489792] AH00489: Apache/2.4.52 (Unix) configured -- resuming normal operations
[Tue Mar 08 14:37:18.610004 2022] [core:notice] [pid 1:tid 140469840489792] AH00094: Command line: 'httpd -D FOREGROUND'
^C
[Tue Mar 08 14:37:47.709363 2022] [mpm_event:notice] [pid 1:tid 140469840489792] AH00491: caught SIGTERM, shutting down


# docker start httpd1
httpd1

确认"NetworkID"和docker0的ID相同，"IPAddress"同网段
# docker inspect httpd1
...输出省略...
                    "NetworkID": "41ff0dd08d0dc2fc3a024dd11220d28a765b9259b4cb3bf30fd472e5d0249de8",
                    "EndpointID": "7081c6af7c0a6804bc0037999c256c8c5b02f5dedeea26e48caa36775afcb667",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
...输出省略...

# ifconfig docker0
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet `172.17.0.1`  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:17ff:fe05:e203  prefixlen 64  scopeid 0x20<link>
        ether 02:42:17:05:e2:03  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 28  bytes 4247 (4.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

```bash
# docker network create --driver bridge net1
f420579a43392df4df8a0140252aa1f5ae77487acbed5a0377c3e0fdaafc4a44
# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
41ff0dd08d0d   bridge    bridge    local
ab5baf7233d9   host      host      local
f420579a4339   net1      bridge    local
8f6bcfc84d2b   none      null      local

# docker network inspect net1
...输出省略...
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"

# docker network create --driver bridge --subnet 172.10.10.0/24 --gateway 172.10.10.1 net2
33ccdc950e0327b18b4e281bd9ac9300223ffdd8a229a2c3a235d79f6524aa12
# docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
41ff0dd08d0d   bridge    bridge    local
ab5baf7233d9   host      host      local
f420579a4339   net1      bridge    local
33ccdc950e03   `net2`      bridge    local
8f6bcfc84d2b   none      null      local

c1 net1
# docker run -itd --name c1 --network net1 centos
609835dad8b5ed94f8a534f50cf926b0f07d54bb4069800dd2f097f6435e6718

c2 net2, dynamic
# docker run -itd --name c2 --network net2 centos
930630ec62393b25302324f2fa5abb07f0a023fd2b58744849fb5c77445da78c

c3 net2, static
# docker run -itd --name c3 --network net2 --ip 172.10.10.10 centos
4cd271c0750b98ea6f035d0341c603018d41526abec29c6ed3d23fe9c96e83d0

# docker inspect c1 | grep -i ipaddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.18.0.2",
# docker inspect c2 | grep -i ipaddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.10.10.2",
# docker inspect c3 | grep -i ipaddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.10.10.10",

网络通
# docker exec -it c2 ping -c 4 172.10.10.10
PING 172.10.10.10 (172.10.10.10) 56(84) bytes of data.
64 bytes from 172.10.10.10: icmp_seq=1 ttl=64 time=0.061 ms
64 bytes from 172.10.10.10: icmp_seq=2 ttl=64 time=0.067 ms
64 bytes from 172.10.10.10: icmp_seq=3 ttl=64 time=0.058 ms
64 bytes from 172.10.10.10: icmp_seq=4 ttl=64 time=0.051 ms

--- 172.10.10.10 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3050ms
rtt min/avg/max/mdev = 0.051/0.059/0.067/0.007 ms

网络不通，使用组合键<Ctrl-C>
# docker exec -it c2 ping -c 4 172.18.0.2
PING 172.18.0.2 (172.18.0.2) 56(84) bytes of data.
^C
--- 172.18.0.2 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss, time 3064ms

将容器c1添加到net2桥接网络
# docker network connect net2 c1
# docker inspect c1 | grep -i ipaddress
            "SecondaryIPAddresses": null,
            "IPAddress": "",
                    "IPAddress": "172.18.0.2",
                    "IPAddress": "172.10.10.3",

网络全通
# docker exec -it c1 ping -c 1 172.10.10.1
PING 172.10.10.1 (172.10.10.1) 56(84) bytes of data.
64 bytes from 172.10.10.1: icmp_seq=1 ttl=64 time=0.083 ms

--- 172.10.10.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.083/0.083/0.083/0.000 ms
# docker exec -it c1 ping -c 1 172.10.10.10
PING 172.10.10.10 (172.10.10.10) 56(84) bytes of data.
64 bytes from 172.10.10.10: icmp_seq=1 ttl=64 time=0.090 ms

--- 172.10.10.10 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.090/0.090/0.090/0.000 ms
```



# 4. 容器存储

## 4.1 容器存储机制

|  ID  |            |                          |                                                             |
| :--: | ---------- | ------------------------ | ----------------------------------------------------------- |
|  1   | tmpfs      |                          | 默认新建的容器，数据存在内存当中                            |
|  2   | volume     | -v 容器内的路径          | 宿主机路径不存在，会自动创建==/var/lib/docker/volumes/...== |
|  3   | bind mount | -v 宿主机路径:容器内路径 | 宿主机路径不存在，会自动创建                                |

### Lab17. 持久存储之volume

```bash
列出卷
# docker volume ls
DRIVER    VOLUME NAME

查看容器web站点主目录
# docker run -d httpd
2b969d04cae5d6e1c6963573405679bf9bf7246c7f2624e948bca5922eced61b
# docker ps
CONTAINER ID   IMAGE     COMMAND              CREATED         STATUS         PORTS     NAMES
2b969d04cae5   httpd     "httpd-foreground"   4 seconds ago   Up 3 seconds   80/tcp    strange_tu
# docker exec -it strange_tu /bin/bash
root@2b969d04cae5:/usr/local/apache2# ls /usr/local/apache2/conf/httpd.conf
root@2b969d04cae5:/usr/local/apache2# grep ^DocumentRoot /usr/local/apache2/conf/httpd.conf
DocumentRoot "/usr/local/apache2/htdocs"
root@2b969d04cae5:/usr/local/apache2#
exit

-v只要有这个选项，主是持久存储
# docker run -d -p 8080:80 -v /usr/local/apache2/htdocs/ httpd
67b946992c5225bf642be94faf734b84ec4fc280d33bab43f8cd3ec6d6ad6d0a
# docker ps
CONTAINER ID   IMAGE     COMMAND              CREATED         STATUS         PORTS                  NAMES
67b946992c52   httpd     "httpd-foreground"   2 seconds ago   Up 2 seconds   0.0.0.0:8080->80/tcp   `agitated_chatelet`
2b969d04cae5   httpd     "httpd-foreground"   2 minutes ago   Up 2 minutes   80/tcp                 strange_tu

# docker volume ls
DRIVER    VOLUME NAME
local     `1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9`

# docker volume inspect 1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9
...输出省略...
        "Mountpoint": "/var/lib/docker/volumes/1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9/_data",
        "Name": "1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9",
...输出省略...

# docker inspect agitated_chatelet
...输出省略...
        "Mounts": [
            {
                "Type": "volume",
                "Name": "1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9",
                "Source": "/var/lib/docker/volumes/1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9/_data",
                "Destination": "/usr/local/apache2/htdocs",
...输出省略...

# cat /var/lib/docker/volumes/1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9/_data/index.html
<html><body><h1>It works!</h1></body></html>
# curl http://localhost:8080
<html><body><h1>It works!</h1></body></html>
```

```bash
修改本地（宿主机）文件，自动 docker cp
# echo haha > /var/lib/docker/volumes/1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9/_data/index.html
# curl http://localhost:8080
haha
```

```bash
默认运行的容器不可删除
# docker rm agitated_chatelet
Error response from daemon: You cannot remove a running container 67b946992c5225bf642be94faf734b84ec4fc280d33bab43f8cd3ec6d6ad6d0a. Stop the container before attempting removal or force remove

--force可强制删除正在运行的容器
# docker rm agitated_chatelet --force
agitated_chatelet

容器删除后，卷依然存在
# docker volume ls
DRIVER    VOLUME NAME
local     1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9

卷存在== 文件存在
# cat /var/lib/docker/volumes/1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9/_data/index.html
haha
```

```bash
可以手动删除卷
# docker volume rm 1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9
1e68643dc6221b2b19e072e03f428ef52c216c6ee9f09d2da50d811fa71b5ab9

确认卷删除
# docker volume ls
DRIVER    VOLUME NAME
```



### Lab18. 持久存储之bind mount

```bash
# ls /root
df  myregistry  snap
# docker run -d -p 8081:80 -v /root/htdocs:/usr/local/apache2/htdocs/ httpd
271527b345fdcfc444948856a456b4d160305b30b3f2b5b1ec1d864c648fc18c

# ls -d /root/htdocs/

# echo haha > /root/htdocs/index.html
# curl http://localhost:8081
haha

# docker exec -it 27 /bin/bash
root@271527b345fd:/usr/local/apache2# cat /usr/local/apache2/htdocs/index.html
haha
root@271527b345fd:/usr/local/apache2#
exit
```

```bash
# docker stop 27
27
# docker rm 27
27
# ls /root/htdocs/
index.html
# cat /root/htdocs/index.html
haha
```



## 4.2 数据共享

### Lab19. 容器间数据共享之bind mount

```bash
# docker run -d --name h1 -p 1001:80 -v /root/htdocs:/usr/local/apache2/htdocs httpd
f0a55b1b960c81231d764301e0b62c358dc391fcb49f93f4db0aa7fe29188a01
# docker run -d --name h2 -p 1002:80 -v /root/htdocs:/usr/local/apache2/htdocs httpd
e8916f0ca1403171799c8ae4c4b3839aaa4f0a62bf1fed0c7fd20ef8dbef29ad

# cat /root/htdocs/index.html
haha
# curl localhost:1001
haha
# curl localhost:1002
haha

# echo hehe > /root/htdocs/index.html
# cat /root/htdocs/index.html
hehe
# curl localhost:1001
hehe
# curl localhost:1002
hehe
```

### Lab20.容器间数据共享之volume container

```bash
新建容器vc，使用bind mount方式
# docker run -d --name vc -v /root/htdocs:/usr/local/apache2/htdocs httpd
075513aeddd3c7c771df60911f69e3b003cbce633650a547343586095bd7c39a

列出容器名称
# docker run -d --name h3 -p 1003:80 --volumes-from <Tab><Tab>
h1  h2  vc

新建两个容器，使用vc容器的卷
# docker run -d --name h3 -p 1003:80 --volumes-from vc httpd
d10673dd799c822c52dd6355e89aa1a55a0cf601412369a30589d8ca71bcdae3
# docker run -d --name h4 -p 1004:80 --volumes-from vc httpd
45c905078444e1e47d775fd340d05891878775a99cae05803eb69b17e95f53c1

检查配置信息
# docker inspect vc | grep -A 4 Mounts
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/root/htdocs",
                "Destination": "/usr/local/apache2/htdocs",
# docker inspect h3 | grep -A 4 Mounts
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/root/htdocs",
                "Destination": "/usr/local/apache2/htdocs",
# docker inspect h4 | grep -A 4 Mounts
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/root/htdocs",
                "Destination": "/usr/local/apache2/htdocs",

测试
# echo new > /root/htdocs/index.html

1003==h3容器的内容，1004==h4容器的内容
# curl localhost:1003
new
# curl localhost:1004
new
```



# 5. 容器底层实现技术

## 5.1 **Namespace** **和** Cgroup

### Lab21. Namespace和Cgroup

```bash
# docker run -itd centos /bin/bash
c7ca03f322fa999926bee76c56920c03a2729aa7e5481c4d3388207c78b23ebd
# docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
c7ca03f322fa   centos    "/bin/bash"   4 seconds ago   Up 3 seconds             hardcore_spence

容器中的进程ID为 1
# docker exec -it c ps axf
    PID TTY      STAT   TIME COMMAND
     14 pts/1    Rs+    0:00 ps axf
    `1` pts/0    Ss+    0:00 /bin/bash

宿主机中的进程ID为 2621
# docker inspect c7ca03f322fa | grep -i pid
            "Pid": 2621,
            "PidMode": "",
            "PidsLimit": null,
# ps aux | grep 2621
root       `2621` 0.0  0.0  12052  3048 pts/0    Ss+  16:18   0:00 /bin/bash
root        2752  0.0  0.0  12116   720 pts/1    S+   16:20   0:00 grep --color=auto 2621

# ls -l /proc/2621/ns/
total 0
lrwxrwxrwx 1 root root 0 3月  15 16:22 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 3月  15 16:19 ipc -> 'ipc:[4026532602]'
lrwxrwxrwx 1 root root 0 3月  15 16:19 mnt -> 'mnt:[4026532600]'
lrwxrwxrwx 1 root root 0 3月  15 16:18 net -> 'net:[4026532605]'
lrwxrwxrwx 1 root root 0 3月  15 16:19 pid -> 'pid:[4026532603]'
lrwxrwxrwx 1 root root 0 3月  15 16:22 pid_for_children -> 'pid:[4026532603]'
lrwxrwxrwx 1 root root 0 3月  15 16:22 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 3月  15 16:22 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 3月  15 16:22 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 3月  15 16:19 uts -> 'uts:[4026532601]'

# docker exec -it hardcore_spence /bin/bash
[root@c7ca03f322fa /]#
[root@c7ca03f322fa /]# ls -l /proc/1/ns/
total 0
lrwxrwxrwx 1 root root 0 Mar 15 08:23 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 ipc -> 'ipc:[4026532602]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 mnt -> 'mnt:[4026532600]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 net -> 'net:[4026532605]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 pid -> 'pid:[4026532603]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 pid_for_children -> 'pid:[4026532603]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 Mar 15 08:23 uts -> 'uts:[4026532601]'
[root@c7ca03f322fa /]# exit
```

```bash
# mount -t cgroup
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,name=systemd)
cgroup on /sys/fs/cgroup/misc type cgroup (rw,nosuid,nodev,noexec,relatime,misc)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
```



## 5.2 容器资源限制

### Lab22. cpu和mem资源限制

```bash
这组实验需要开启3个终端

终端1，https://hub.docker.com/r/progrium/stress
# docker run  --name yl1 -it -c 1024 progrium/stress --cpu 1
终端2,CPU 100%
# top
<q>退出

终端2，https://hub.docker.com/r/polinux/stress-ng
# docker run --name yl2 -it -c 1024 polinux/stress-ng --cpu 1
终端3，两个容器各点一半CPU，因为权重值相同
# top
<q>

-f, --filter=
# docker ps -f name="yl*"
# cat /sys/fs/cgroup/cpu/docker/3a8dfa463c2fd19b4c293d2b71cb3f5601a0743e09902eed8f67161ccbd0d213/cpu.shares
# cat /sys/fs/cgroup/cpu/docker/3a8dfa463c2fd19b4c293d2b71cb3f5601a0743e09902eed8f67161ccbd0d213/tasks
# ps -aux | grep 3986
# ps -aux | grep 4016
# cat /proc/3986/cgroup

实验看到现象后，终端1和2分别<Ctrl-C>中止
```

```bash
# ls /sys/fs/cgroup/memory/

# docker run -it -m 400M --memory-swap=500M progrium/stress --vm 1 --vm-bytes 450M
```



# 6. PaaS概述

## 6.1 什么是PaaS

| 缩写 |            IaaS/架构             |         PaaS/平台          |          SaaS/软件           |
| :--: | :------------------------------: | :------------------------: | :--------------------------: |
| 全拼 | **Infrastructure**-as-a-Service  | **Platform**-as-a-Service  |  **Software**-as-a-Service   |
| 中文 |          基础设施即服务          |         平台即服务         |          软件即服务          |
| 示例 | 亚马逊，阿里云、华为云、腾讯云等 | Google、Microsoft Azure 等 | 阿里的钉钉、苹果的 iCloud 等 |
| 软件 |            OpenStack             |       OpenShift、K8S       |          Office 365          |

## 6.2 PaaS与编排工具概述



# 7. Kubernetes架构介绍

## 7.1 Kubernetes架构

### <a name=lab23>lab23.</a> [使用 kubeadm 引导集群之新建虚拟机安装系统](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/)

- 新建虚拟机安装系统（参考https://gitee.com/suzhen99/k8s）,20分钟

  > ## - VMware 虚拟机
  >
  > ## - 安装 [Ubuntu 18.04 LTS](https://gitee.com/link?target=https%3A%2F%2Freleases.ubuntu.com%2F18.04%2Fubuntu-18.04.6-desktop-amd64.iso.torrent)
  >
  > ​	1-8

### <a name=lab24>lab24.</a> 使用 kubeadm 引导集群之布署集群

- 布署集群（参考https://gitee.com/suzhen99/k8s），20分钟

  > 9-10

**[kiosk@k8s-master]**

```bash
$ kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler           `Healthy`  `ok`                              
etcd-0              `Healthy`  {"health":"true","reason":""}   
controller-manager  `Healthy`  `ok`

$ kubectl get nodes 
NAME         STATUS   ROLES                  AGE    VERSION
k8s-master  `Ready`   control-plane,master   2m5s   `v1.23.1`

$ kubectl get pod -n kube-system 
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-56fcbf9d6b-lw2xc   1/1     Running   0          3m18s
calico-node-625rk                          1/1     Running   0          3m18s
coredns-6d8c4cb4d-98hzd                    1/1     Running   0          3m18s
coredns-6d8c4cb4d-lxtnx                    1/1     Running   0          3m18s
etcd-k8s-master                            1/1     Running   0          3m24s
kube-apiserver-k8s-master                  1/1     Running   0          3m24s
kube-controller-manager-k8s-master         1/1     Running   0          3m21s
kube-proxy-f7fq9                           1/1     Running   0          3m18s
kube-scheduler-k8s-master                  1/1     Running   0          3m21s
```

[可选]环境搭建完成，建议做一个关机**快照**，名称建议==INIT==

[Kubernetes 文档](https://kubernetes.io/zh/docs/) / [概念](https://kubernetes.io/zh/docs/concepts/) / [概述](https://kubernetes.io/zh/docs/concepts/overview/) / [使用 Kubernetes 对象](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/) / [字段选择器](https://kubernetes.io/zh/docs/concepts/overview/working-with-objects/field-selectors/)

```bash
# systemctl status docker

# systemctl status kubelet

# kubectl get pods --namespace=kube-system --field-selector spec.nodeName=k8s-master
# kubectl get pods --namespace=kube-system --field-selector spec.nodeName=k8s-worker1
# kubectl get pods -n kube-system --field-selector spec.nodeName=k8s-worker2
```



## 7.2 namespace

### Lab24. namespapce

```bash
$ kubectl api-resources --namespaced=true

$ kubectl get namespace

$ kubectl get pod --namespace=kube-system
$ kubectl get pod -n kube-system
```



# 8. Deployment管理与使用

## 8.2 创建 Deployment

### Lab25. Deployment-cmd

```bash
$ kubectl create deployment mydep --image=nginx

$ kubectl get deployment

$ kubectl describe deployments.apps mydep

$ kubectl get deployment
```

### Lab26. Deployment-[yaml](https://kubernetes.io/zh/docs/tasks/run-application/run-stateless-application-deployment/)

|  ID  |        NAME        |     IMAGE      | REPLICAS |
| :--: | :----------------: | :------------: | :------: |
|  1   | deployment-v1.yaml | nginx:`1.14.2` |    2     |
|  2   | deployment-v2.yaml | nginx:`1.20.2` |    3     |
|  3   | deployment-v3.yaml | nginx:`1.21.6` |    3     |

```bash
$ vim deployment-v1.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

```bash
$ kubectl create -f deployment-v1.yaml

$ kubectl get deployment
```

## 8.3 升级和弹性收缩

### Lab27. Deployment弹性伸缩 

```bash
$ vim deployment-v2.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.20.2
        ports:
        - containerPort: 80
```

```bash
$ kubectl apply -f deployment-v2.yaml

$ kubectl get deployment
```

> kubectl **scale**

```bash
$ kubectl scale deployment nginx-deployment --replicas=2

$ kubectl get deployment
```

### Lab28. Deployment升级软件版本

```bash
$ kubectl get rs

$ kubectl get pods

$ vim deployment-v3.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        ports:
        - containerPort: 80
```

```bash
$ kubectl apply -f deployment-v3.yaml

$ kubectl get pods

$ kubectl describe deployments.apps nginx-deployment
```

> rollout
>
>  --record

```bash
$ kubectl rollout history deployment nginx-deployment

$ kubectl apply -f deployment-v1.yaml --record
$ kubectl apply -f deployment-v2.yaml --record
$ kubectl apply -f deployment-v3.yaml --record

$ kubectl rollout history deployment nginx-deployment

$ kubectl rollout history deployment nginx-deployment --revision=5

$ kubectl rollout undo deployment nginx-deployment --to-revision=5
```



# 9. Pod管理与使用

## 9.2 使用pod

### Lab29.  创建一个pod
```bash
$ vim mypod.yaml
```

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
      image: busybox
      args:
      - /bin/sh
      - -c
      - sleep 3h
```

```bash
$ kubectl create -f mypod.yaml

$ kubectl get pod mypod

$ kubectl get pod mypod -owide

$ ssh root@k8s-worker2 docker ps | grep mypod
```

```bash
$ kubectl describe pod mypod

$ kubectl exec -it mypod -- /bin/sh
/ # exit

$ kubectl exec -it mypod --container mypod -- /bin/sh
/ # exit
```

### Lab30.  创建第二个pod

```yaml
kubectl apply -f- <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: helloworld
spec:
  restartPolicy: Never
  containers:
    - name: helloworld
      image: hello-world
EOF

```

```bash
$ kubectl describe pod helloworld

$ kubectl get pods
```

```bash
$ kubectl delete pod helloworld

$ kubectl delete pod mypod
```



# 10. Label与Label Selector

## 10.1 Label

### Lab31. 设置标签

- 添加标签-创建时

```yaml
kubectl apply -f- <<EOF
kind: Pod
apiVersion: v1
metadata:
  name: labelpod
  labels:
    app: busybox
    version: new
spec:
  containers:
    - name: labelpod
      image: busybox
      args:
      - /bin/sh
      - -c
      - sleep 30000
EOF
```

- 查看标签（--show-labels）

```bash
$ kubectl get pods labelpod --show-labels
NAME       READY   STATUS    RESTARTS   AGE   LABELS
labelpod   1/1     Running   0          20s   `app=busybox`,`version=new`
```

- 添加标签-存在时

```bash
$ kubectl label pods labelpod time=2022

$ kubectl get pods labelpod --show-labels
```

- 删除标签

```bash
$ kubectl label pod labelpod time-
pod/labelpod unlabeled
```

## 10.2 Label Selector

### Lab32. 标签选择器

```bash
$ kubectl get pods -l time=2022 --show-labels

$ kubectl get pods -l time!=2022 --show-labels

$ kubectl get pod -L app

$ kubectl get pod -l app=nginx
```

```bash
$ kubectl label nodes k8s-worker1 env=test

$ kubectl get node -L env

$ kubectl get nodes --show-labels
```

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
# 增加 2 行        
      nodeSelector:
        env: test
EOF
```

```bash
$ kubectl get pods -l app=nginx -owide
```

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
# 增加 9 行
      affinity:
        nodeAffinity:
         requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: env
                operator: In
                values:
                - test
EOF

```

```bash
$ kubectl get pods -l app=nginx -owide
```



# 11. Service服务发现

## 11.2 服务发现

### Lab33. 创建Service

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: httpd-svc
spec:
  selector:
    app: httpd
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
EOF

```

```bash
$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
httpd-svc    ClusterIP  `10.100.247.72`  <none>       `8080`/TCP   10s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    23d

$ curl 10.100.247.72:8080
<html><body><h1>It works!</h1></body></html>
```

```bash
$ kubectl get endpoints httpd-svc
NAME        ENDPOINTS                                            AGE
httpd-svc   172.16.126.13:80,172.16.126.14:80,172.16.194.82:80   30m

$ curl 172.16.126.13
<html><body><h1>It works!</h1></body></html>
```

```bash
$ kubectl describe svc httpd-svc
Name:              httpd-svc
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=httpd
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.100.247.72
IPs:               10.100.247.72
Port:              <unset>  8080/TCP
TargetPort:        80/TCP
Endpoints:         172.16.126.13:80,172.16.126.14:80,172.16.194.82:80
Session Affinity:  None
Events:            <none>
```

### Lab34. 创建可供外部访问的Service

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Service
metadata:
  name: httpd-svc
spec:
# 添加 1 行
  type: NodePort
  selector:
    app: httpd
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
# 添加 1 行，不指明随机
    nodePort: 30144
EOF

```

```bash
$ kubectl get svc httpd-svc
NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
httpd-svc  `NodePort`  10.100.247.72   <none>        8080:`30144`/TCP 29m

$ curl k8s-worker1:30144
<html><body><h1>It works!</h1></body></html>

$ curl k8s-worker2:30144
<html><body><h1>It works!</h1></body></html>
```

## 11.3 集群中的DNS

### Lab35. 集群中的DNS

```bash
$ kubectl -n kube-system get pods | grep dns
`coredns`-6d8c4cb4d-28tj5    1/1     Running   1 (23d ago)   23d
`coredns`-6d8c4cb4d-jxxtc    1/1     Running   1 (23d ago)   23d
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: clientpod
spec:
  containers:
    - name: clientpod
      image: busybox:1.28.3
      args:
      - /bin/sh
      - -c
      - sleep 3h
EOF

```

```bash
$ kubectl get svc httpd-svc
NAME        TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
httpd-svc   NodePort `10.100.247.72`   <none>        8080:30144/TCP   50m

$ kubectl exec -it clientpod -- /bin/sh
/ # nslookup 10.100.247.72
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      10.100.247.72
Address 1: 10.100.247.72 httpd-svc.default.svc.cluster.local
/ # wget httpd-svc:8080

/ # exit
```

## 11.4 Headless service

### Lab36. Headless Service

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: headless-svc
spec:
  selector:
    app: httpd
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  clusterIP: None
EOF

```

```bash
$ kubectl get svc
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
headless-svc   ClusterIP  `None`           <none>        80/TCP           23s
httpd-svc      NodePort    10.100.247.72   <none>        8080:30144/TCP   58m
kubernetes     ClusterIP   10.96.0.1       <none>        443/TCP          23d

$ kubectl exec -it clientpod -- /bin/sh
/ # nslookup headless-svc
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      headless-svc
Address 1: 172.16.126.13 172-16-126-13.httpd-svc.default.svc.cluster.local
Address 2: 172.16.126.14 172-16-126-14.httpd-svc.default.svc.cluster.local
Address 3: 172.16.194.82 172-16-194-82.httpd-svc.default.svc.cluster.local

/ # wget headless-svc
Connecting to headless-svc (172.16.126.14:80)
index.html           100%    45   0:00:00 ETA
```



# 12. DaemonSet与Job.pptx

## 12.1 DaemonSet

### Lab37. DaemonSet-1

```bash
$ kubectl -n kube-system get daemonsets.apps
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
`calico-node` 3         3         3       3            3           kubernetes.io/os=linux   29d
`kube-proxy`  3         3         3       3            3           kubernetes.io/os=linux   29d
```

```bash
$ kubectl -n kube-system describe daemonsets.apps kube-proxy | grep -i label
Labels:        `k8s-app=kube-proxy`
  Labels:          `k8s-app=kube-proxy`

$ kubectl -n kube-system get pod -l k8s-app=kube-proxy -o wide
NAME               READY   STATUS    RESTARTS      AGE   IP                NODE          NOMINATED NODE   READINESS GATES
kube-proxy-8pv56   1/1     Running   1 (29d ago)   29d   192.168.147.129   k8s-worker1   <none>           <none>
kube-proxy-9q8bq   1/1     Running   1 (29d ago)   29d   192.168.147.128   k8s-master    <none>           <none>
kube-proxy-tqvrs   1/1     Running   1 (29d ago)   29d   192.168.147.130   k8s-worker2   <none>           <none>
```

```bash
$ kubectl -n kube-system describe daemonsets.apps calico-node | grep -i label
Labels:        `k8s-app=calico-node`
  Labels:           `k8s-app=calico-node`

$ kubectl -n kube-system get pod -l k8s-app=calico-node -o wide
NAME                READY   STATUS    RESTARTS      AGE   IP                NODE          NOMINATED NODE   READINESS GATES
calico-node-75k64   1/1     Running   1 (29d ago)   29d   192.168.147.130   k8s-worker2   <none>           <none>
calico-node-cxqxc   1/1     Running   1 (29d ago)   29d   192.168.147.128   k8s-master    <none>           <none>
calico-node-g5wj7   1/1     Running   1 (29d ago)   29d   192.168.147.129   k8s-worker1   <none>           <none>
```

### Lab38. DaemonSet-2

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
       app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
EOF

```

```bash
$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP              NODE          NOMINATED NODE   READINESS GATES
nginx-daemonset-vqfpw   1/1     Running   0          63s   172.16.126.1    k8s-worker2   <none>           <none>
nginx-daemonset-z87sj   1/1     Running   0          63s   172.16.194.65   k8s-worker1   <none>           <none>

$ kubectl delete pod nginx-daemonset-vqfpw
pod "nginx-daemonset-vqfpw" deleted

$ kubectl get pod -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP              NODE          NOMINATED NODE   READINESS GATES
`nginx-daemonset-4r8mj` 1/1     Running   0         `2s`     172.16.126.2    k8s-worker2   <none>           <none>
nginx-daemonset-z87sj   1/1     Running   0          3m15s   172.16.194.65   k8s-worker1   <none>           <none>
```

```bash
$ ssh root@k8s-worker1 halt -p

$ kubectl get daemonset
NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
nginx-daemonset  `1`        1         1       1            1           <none>          7m37s
```

## 12.2 Job

### Lab39. job

```yaml
kubectl apply -f- <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  backoffLimit: 4
EOF

```

```bash
$ kubectl get job
NAME   COMPLETIONS   DURATION   AGE
pi     1/1           33s        68s

$ kubectl get pods
NAME                    READY   STATUS      RESTARTS   AGE
`pi-ht7xr`              0/1    `Completed`  0          2m13s

$ kubectl logs pi-ht7xr
3.1415926...
```

## 12.3 CronJob

### Lab40. CronJob

```yaml
kubectl apply -f- <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
EOF

```

```bash
$ kubectl describe cronjobs.batch hello
...输出省略...
Events:
  Type    Reason            Age   From                Message
  ----    ------            ----  ----
  Normal  SuccessfulCreate  79m   cronjob-controller  Created job hello-27547692
  Normal  SawCompletedJob   79m   cronjob-controller  Saw completed job: hello-27547692, status: Complete
  Normal  SuccessfulCreate  78m   cronjob-controller  Created job hello-27547693
  Normal  SawCompletedJob   78m   cronjob-controller  Saw completed job: hello-27547693, status: Complete
  Normal  SuccessfulCreate  77m   cronjob-controller  Created job hello-27547694
  Normal  SawCompletedJob   77m   cronjob-controller  Saw completed job: hello-27547694, status: Complete
...输出省略...
```



# 13. Pod健康检查

## 13.2 使用探针

### Lab41. livenessProbe-exec
```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    image: busybox
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

```

```bash
$ kubectl get pod liveness-exec
NAME            READY   STATUS    RESTARTS     AGE
liveness-exec   1/1     Running  `1`(5s ago)   80s

$ kubectl describe pod liveness-exec

$ kubectl describe pod liveness-exec | grep -i liveness:.*exec
    Liveness:       exec [cat /tmp/healthy] delay=5s timeout=1s period=5s #success=1 #failure=3
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
# name: liveness-exec
  name: liveness-exec3
spec:
  containers:
  - name: liveness
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    image: busybox
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
      # 增加 1 行
      timeoutSeconds: 3
EOF

```

```bash
$ kubectl describe pod liveness-exec3 | grep -i liveness:.*exec
    Liveness:       exec [cat /tmp/healthy] delay=5s timeout=`3s` period=5s #success=1 #failure=3
```

### Lab42. livenessProbe-http

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: mirrorgooglecontainers/liveness
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
EOF

```

```bash
$ kubectl get pod liveness-http
NAME            READY   STATUS    RESTARTS   AGE
liveness-http   1/1     Running   0          41s

$ kubectl describe pod liveness-http | grep -i liveness:.*http
    Liveness:      `http-get` http://:8080/healthz delay=3s timeout=1s period=3s #success=1 #failure=3
```

### Lab43. livenessProbe-tcp

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
  labels:
    app: ubuntu
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    args:
    - /bin/sh
    - -c
    - apt-get update && apt-get -y install openbsd-inetd telnetd && /etc/init.d/openbsd-inetd start; sleep 30000
    livenessProbe:
      tcpSocket:
        port: 23
      initialDelaySeconds: 60
      periodSeconds: 20
EOF

```

```bash
$ kubectl get pod ubuntu
NAME     READY   STATUS    RESTARTS   AGE
ubuntu   1/1     Running   0          2m32s

$ kubectl describe pod ubuntu | grep -i live
    Liveness:      `tcp-socket` :23 delay=60s timeout=1s period=20s #success=1 #failure=3
```

## 13.3 使用就绪探针

### Lab44. readinessProbe-exec

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
        readinessProbe:
          exec:
            command:
            - cat
            - /usr/local/apache2/htdocs/index.html
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: httpd-svc
spec:
  selector:
    app: httpd
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
EOF

```

```bash
$ kubectl get endpoints httpd-svc
NAME        ENDPOINTS                                            AGE
httpd-svc   172.16.126.57:80,172.16.126.58:80,172.16.126.59:80   97s

$ kubectl get pod -l app=httpd
NAME                              READY   STATUS    RESTARTS   AGE
httpd-deployment-c459d5dd-6pxl5   1/1     Running   0          84s
httpd-deployment-c459d5dd-79nvd   1/1     Running   0          84s
httpd-deployment-c459d5dd-vmlh2   1/1     Running   0          84s
```

```bash
$ kubectl exec -it httpd-deployment-c459d5dd-6pxl5 -- /bin/sh
# rm /usr/local/apache2/htdocs/index.html
# exit
```

```bash
$ kubectl get endpoints httpd-svc
NAME        ENDPOINTS                           AGE
httpd-svc   172.16.126.57:80,172.16.126.58:80   5m12s

$ kubectl get pods -l app=httpd
NAME                              READY   STATUS    RESTARTS   AGE
httpd-deployment-c459d5dd-6pxl5   0/1     Running   0          5m42s
httpd-deployment-c459d5dd-79nvd   1/1     Running   0          5m42s
httpd-deployment-c459d5dd-vmlh2   1/1     Running   0          5m42s

$ kubectl describe pod httpd-deployment-c459d5dd-6pxl5
...输出省略...
  Warning  Unhealthy  58s (x22 over 2m33s)  kubelet            Readiness probe failed: cat: /usr/local/apache2/htdocs/index.html: No such file or directory
```



# 14. Kubernetes网络

## 14.1 Kubernetes 网络模型

### Lab45. Node与Pod之间通信实验

```bash
$ kubectl run nginx --image=nginx --port 80

$ kubectl get pod -owide
NAME   READY   STATUS   RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
nginx  1/1     Running  0          27s     172.16.126.3  `k8s-worker2`  <none>           <none>

$ curl 172.16.126.3
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
...输出省略...

$ ip route
...输出省略...
172.16.235.196 dev cali46502c0485c scope link
172.16.235.197 dev cali29fae187fa2 scope link
172.16.235.198 dev cali2bab3c78e13 scope link
...输出省略...
```

### Lab46. Pod与Pod之间通信实验

```bash
$ kubectl run busybox --image=busybox -- sleep 3h

$ kubectl get pod -o wide
NAME       READY   STATUS     RESTARTS     AGE    IP                     NODE
busybox    1/1         Running    0                 27s       172.16.194.71   k8s-worker1
...输出省略
```

```bash
$ kubectl exec -it busybox -- /bin/sh
/ # ping 172.16.126.3
PING 172.16.126.3 (172.16.126.3): 56 data bytes
64 bytes from 172.16.126.3: seq=0 ttl=62 time=0.611 ms
...输出省略...
/ # telnet 172.16.126.3 80
Connected to 172.16.126.3
get
...输出省略...
<hr><center>nginx/1.21.5</center>
</body>
</html>
Connection closed by foreign host
/ # exit
```

### Lab46. 集群外访问-NodePort

```bash
$ kubectl get pod --show-labels
NAME     READY   STATUS  RESTARTS   AGE. LABELS
busybox  1/1        Running  0                17m  run=busybox
nginx    1/1        Running  0                42m  run=nginx
...
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-access
spec:
  selector:
    run: nginx
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF

```

```bash
$ kubectl get svc -o wide
NAME          TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)           AGE  SELECTOR
kubernetes    ClusterIP  10.96.0.1      <none>       443/TCP           30d   <none>
nginx-access  NodePort   10.110.109.55  <none>       80:`30080`/TCP    68s   run=nginx

$ curl http://k8s-master:30080
...
<h1>Welcome to nginx!</h1>
...

$ ss -ntlp | grep 30080
LISTEN  0       4096              0.0.0.0:30080          0.0.0.0:*
```



# 15. Kubernetes存储

## 15.1 EmptyDir

### Lab47. 创建一个使用EmptyDir的Pod
```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: em
spec:
  containers:
  - image: ubuntu
    name: test-container
    # 下 3 行
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
    args:
    - /bin/sh
    - -c
    - sleep 30000
# 下 3 行
  volumes:
  - name: cache-volume
    emptyDir: {}
EOF

```

```bash
$ kubectl describe pod em | grep -A 1 Mount
    Mounts:
     `/cache`from `cache-volume` (rw)

$ kubectl describe pod em | grep -A 4 ^Volume
Volumes:
  `cache-volume`:
    Type:       `EmptyDir` (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  `<unset>`
```

```bash
$ kubectl exec -it em -- /bin/sh
# ls /cache
# touch /cache/my.txt
# exit
```

### Lab48. EmptyDir容量限制

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: em1
spec:
  containers:
  - image: ubuntu
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
    args:
    - /bin/sh
    - -c
    - sleep 30000
  volumes:
  - name: cache-volume
  # 下 2 行区别
    emptyDir:
      sizeLimit: 1Gi
EOF

```

```bash
$ kubectl describe pod em1 | grep -A 4 ^Volume
Volumes:
  cache-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit: `1Gi`
```

```bash
$ kubectl exec -it em1 -- /bin/sh
# df -h
Filesystem                         Size  Used Avail Use% Mounted on
overlay                             38G  4.5G   32G  13% /
/dev/mapper/ubuntu--vg-ubuntu--lv  `38G` 4.5G   32G  13% /cache
shm                                 64M     ...
# dd if=/dev/zero of=/cache/test2g bs=1M count=2048
# exit
```

```bash
$ kubectl get pod em1
NAME   READY   STATUS    RESTARTS   AGE
em1    0/1    `Evicted`  1          53m
```

## 15.2 hostPath

### Lab49. hostPath

```bash
$ kubectl -n kube-system get pod kube-proxy-8pv56 -o yaml | grep -A 12 volumes:
  volumes:
  ...输出省略...
  - hostPath:
      path: /run/xtables.lock
      type: FileOrCreate
    name: xtables-lock
  - hostPath:
      path: /lib/modules
      type: ""
    name: lib-modules
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: hppod
spec:
  containers:
  - image: ubuntu
    name: hp-container
    volumeMounts:
    - mountPath: /hp-dir
      name: hp-volume
    args:
    - /bin/sh
    - -c
    - sleep 30000
  volumes:
  - name: hp-volume
    hostPath:
      path: /mnt/hostpathdir
      type: DirectoryOrCreate
EOF

```

```bash
$ kubectl get pod hppod -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
hppod   1/1     Running   0          29s   172.16.126.9  `k8s-worker2`  <none>           <none>

$ ssh root@k8s-worker2 ls /mnt
hostpathdir
```

## 15.3 PV和PVC

### Lab50. PV和PVC

**[kiosk@192.168.147.128]**

```bash
sudo apt -y install nfs-kernel-server && \
sudo mkdir /nfs
echo '/nfs *(rw,no_root_squash)' | sudo tee /etc/exports
sudo systemctl enable nfs-server
sudo systemctl restart nfs-server
showmount -e

```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs
    server: 192.168.147.128
EOF

```

```bash
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mypv   1Gi        RWO            Recycle          Available                                   9s
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeName: mypv
  resources:
    requests:
      storage: 1Gi
EOF

```

```bash
$ kubectl get pvc
NAME    STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mypvc   Bound    mypv     1Gi        RWO                           7s
```

```bash
$ kubectl delete pvc mypvc && kubectl get pod
persistentvolumeclaim "mypvc" deleted
NAME                               READY   STATUS                   RESTARTS       AGE
...输出省略...
`recycler-for-mypv`                0/1     ContainerCreating        0              0s
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
# 只修改 1 行
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /nfs
    server: 192.168.147.128
EOF

```

```bash
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mypv   1Gi        RWO           `Retain`          Available
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeName: mypv
  resources:
    requests:
      storage: 1Gi
EOF

```

```bash
$ kubectl delete pvc mypvc
persistentvolumeclaim "mypvc" deleted

$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM           STORAGECLASS   REASON   AGE
mypv   1Gi        RWO            Retain          `Released`  default/mypvc                           5m46s
```



# 16. ConfigMap与Secret

## 16.1 ConfigMap介绍

### Lab51. 创建ConfigMap

```bash
sudo mkdir -p /runfile/configmap

sudo tee /runfile/configmap/game.properties <<EOF
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
EOF

sudo tee /runfile/configmap/ui.properties <<EOF
color.good=purple
how.nice.to.look=fairlyNice
EOF
```

> - Folder
>   --from-file

```bash
$ kubectl create configmap game-config --from-file=/runfile/configmap

$ kubectl get configmap
NAME               DATA   AGE
`game-config`      2      5s
kube-root-ca.crt   1      31d

$ kubectl describe configmaps game-config 
...输出省略...
Data
====
game.properties:
----
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten

ui.properties:
----
color.good=purple
how.nice.to.look=fairlyNice
...输出省略...
```

> - File: ini
>   --from-file

```bash
$ kubectl create configmap game-config-3 \
  --from-file=/runfile/configmap/game.properties \
  --from-file=/runfile/configmap/ui.properties

$ kubectl get configmap
NAME               DATA   AGE
game-config        2      112s
`game-config-3`    2      12s
kube-root-ca.crt   1      31d

$ kubectl describe configmaps game-config-3
...输出省略...
Data
====
game.properties:
----
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten

ui.properties:
----
color.good=purple
how.nice.to.look=fairlyNice
...输出省略...
```

> --from-literal

```bash
$ kubectl create configmap special-config \
--from-literal=special.how=very \
--from-literal=special.type=charm

$ kubectl get configmaps
NAME               DATA   AGE
game-config        2      2m54s
game-config-3      2      74s
kube-root-ca.crt   1      31d
`special-config`   2      8s

$ kubectl describe configmaps special-config
...输出省略...
Data
====
special.how:
----
very
special.type:
----
charm
...输出省略...
```

> - File: yaml
>   --from-file

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: specialconfig-2
data:
  key1: value1
  pro.property: |
    key2: value2
    key3: value3
EOF

```

```bash
$ kubectl get configmaps
NAME               DATA   AGE
game-config        2      4m
game-config-3      2      2m20s
kube-root-ca.crt   1      31d
special-config     2      74s
`specialconfig-2`  2      15s

$ kubectl describe configmaps specialconfig-2
...输出省略...
Data
====
pro.property:
----
key2: value2
key3: value3

key1:
----
value1
...输出省略...
```

### Lab52. 使用ConfigMap

> - envFrom

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cm-test-pod
spec:
  containers:
    - name: cm-container
      image: busybox
      args: [  "/bin/sh", "-c", "sleep 3000" ]
      env:
        - name: special-env
          valueFrom:
            configMapKeyRef:
              name: specialconfig-2
              key: key1
      envFrom:
        - configMapRef:
            name: specialconfig-2
  restartPolicy: Never
EOF

```

```bash
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
cm-test-pod   1/1     Running   0          26s

$ kubectl exec -it cm-test-pod  -- /bin/sh
/ # env
...输出省略...
key1=value1
pro.property=key2: value2
key3: value3
...输出省略...
/ # exit
```

> - volume

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: cmpod2
spec:
  containers:
  - name: cmpod2
    image: busybox
    args: [ "/bin/sh", "-c", "sleep 3000" ]
    volumeMounts:
    - name: db
      mountPath: "/etc/db"
      readOnly: true
  volumes:
  - name: db
    configMap:
      name: specialconfig-2
EOF

```

```bash
$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
cm-test-pod   1/1     Running   0          6m2s
cmpod2        1/1     Running   0          28s

$ kubectl exec -it cmpod2 -- /bin/sh
/ # ls /etc/db
key1          pro.property
/ # cat /etc/db/key1
value1/ # cat /etc/db/pro.property
key2: value2
key3: value3
# exit
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: specialconfig-2
data:
  key1: value-new
  pro.property: |
    key2: value2
    key3: value3
EOF

```

```bash
$ kubectl exec -it cmpod2 -- /bin/sh
/ # cat /etc/db/key1
value-new
# exit
```



## 16.2 Secret介绍

### Lab52. 创建Secret

> - file

```bash
$ echo -n "admin" > username.txt
$ echo -n "mima" > password.txt
```

```bash
$ kubectl create secret generic db-user-pass \
--from-file=./username.txt \
--from-file=./password.txt

$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
`db-user-pass`        Opaque                                2      6s
default-token-7zfdn   kubernetes.io/service-account-token   3      31d

$ kubectl describe secrets db-user-pass
...输出省略...
Data
====
password.txt:  4 bytes
username.txt:  5 bytes
```

> - file: yaml

```bash
$ echo -n "admin" | base64
YWRtaW4=

$ echo -n "mima" | base64
bWltYQ==
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: bWltYQ==
EOF

```

```bash
$ kubectl get secrets mysecret
NAME       TYPE     DATA   AGE
mysecret   Opaque   2      13s

$ kubectl describe secrets mysecret
...输出省略...
Data
====
password:  4 bytes
username:  5 bytes
```

### Lab53. 使用Secret

> 挂载全部值

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: spod
spec:
  containers:
  - image: busybox
    name: spod
    args: ["/bin/sh","-c","sleep 3000"]
    volumeMounts:
    - name: secrets
      mountPath: "/etc/secret"
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: mysecret
EOF

```

```bash
$ kubectl get pods spod
NAME   READY   STATUS    RESTARTS   AGE
spod   1/1     Running   0          10s

$ kubectl exec -it spod -- /bin/sh
/ # ls /etc/secret
password  username
/ # cat /etc/secret/username
admin/ # cat /etc/secret/password
mima/ # exit
```

> 挂载指定值

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: spod2
spec:
  containers:
  - image: busybox
    name: spod2
    args: ["/bin/sh","-c","sleep 3000"]
    volumeMounts:
    - name: secrets
      mountPath: "/etc/secret"
      readOnly: true
  volumes:
  - name: secrets
    secret:
      secretName: mysecret
      items:
      - key: password
        path: my-group/my-passwd
EOF

```

```bash
$ kubectl get pod spod2
NAME    READY   STATUS    RESTARTS   AGE
spod2   1/1     Running   0          58s

$ kubectl exec -it spod2 -- /bin/sh
/ # ls /etc/secret
my-group
/ # ls /etc/secret/my-group/
my-passwd
/ # cat /etc/secret/my-group/my-passwd
mima/ # exit
```



# 17. StatefulSet管理与使用

## 17.1 使用StatefulSet

### Lab54. StatefulSet

```bash
sudo mkdir /etc/exports.d /nfs{1..3} && \
sudo tee /etc/exports.d/s.exports <<EOF
/nfs1 *(rw,no_root_squash)
/nfs2 *(rw,no_root_squash)
/nfs3 *(rw,no_root_squash)
EOF
sudo apt -y install nfs-kernel-server && \
sudo systemctl enable nfs-server && \
sudo systemctl restart nfs-server && \
showmount -e

```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv1
spec:
  storageClassName: my-sc
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs1
    server: 192.168.147.128
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv2
spec:
  storageClassName: my-sc
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs2
    server: 192.168.147.128
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv3
spec:
  storageClassName: my-sc
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs3
    server: 192.168.147.128
EOF

```

```bash
$ kubectl get pv
NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
mypv1   1Gi        RWO            Recycle          Available           my-sc                   41s
mypv2   1Gi        RWO            Recycle          Available           my-sc                   41s
mypv3   1Gi        RWO            Recycle          Available           my-sc                   10s
```

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: nginx
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: stor
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: stor
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-sc"
      resources:
        requests:
          storage: 1Gi
EOF

```

```bash
$ watch -n 1 kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
`web-0` 1/1     Running   0          79s
`web-1` 1/1     Running   0          55s
`web-2` 1/1     Running   0          30s
<Ctrl-C>

$ kubectl get pvc
NAME         STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
stor-web-0   Bound    mypv1    1Gi        RWO            my-sc          112s
stor-web-1   Bound    mypv2    1Gi        RWO            my-sc          88s
stor-web-2   Bound    mypv3    1Gi        RWO            my-sc          63s
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
EOF

```

```bash
$ kubectl get svc nginx
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   None         <none>        80/TCP    15s
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: clientpod
spec:
  containers:
    - name: clientpod
      image: busybox:1.28.3
      args:
      - /bin/sh
      - -c
      - sleep 3h
EOF

```

```bash
$ kubectl exec -it clientpod -- /bin/sh
/ # nslookup nginx
...输出省略...
Name:      nginx
Address 1: 172.16.194.66 web-2.nginx.default.svc.cluster.local
Address 2: 172.16.126.1 web-0.nginx.default.svc.cluster.local
Address 3: 172.16.194.65 web-1.nginx.default.svc.cluster.local
/ # nslookup web-0.nginx
...输出省略...
Name:      web-0.nginx
Address 1: 172.16.126.1 web-0.nginx.default.svc.cluster.local
```

### Lab55. StatefulSet的故障处理

```bash
$ sudo touch /nfs1/newfile

$ kubectl exec -it web-1 -- ls /usr/share/nginx/html
newfile

$ kubectl exec -it clientpod -- nslookup web-1.nginx
...输出省略...
Address 3: 172.16.194.`65` web-1.nginx.default.svc.cluster.local

$ kubectl delete pod web-1
pod "web-1" deleted

$ kubectl exec -it clientpod -- nslookup web-1.nginx
...输出省略...
Name:      web-1.nginx
Address 1: 172.16.194.`67` web-1.nginx.default.svc.cluster.local

$ k exec -it web-1 -- ls /usr/share/nginx/html
newfile
```

### Lab56. 扩缩容和升级

```bash
$ watch -n 1 kubectl get pod
```

新开个终端

```bash
$ kubectl scale statefulset web --replicas=1

$ kubectl scale statefulset web --replicas=3
```

### Lab57. Pod管理策略

```bash
$ kubectl delete statefulsets.apps web

$ kubectl delete pvc stor-web-0 stor-web-1 stor-web-2

$ kubectl get svc

$ kubectl get pv
```

```yaml
kubectl apply -f- <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: nginx
  # 增加 1 行
  podManagementPolicy: "Parallel"
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: stor
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: stor
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "my-sc"
      resources:
        requests:
          storage: 1Gi
EOF

```

```bash
$ watch -n 1 kubectl get pod
```

新开个终端

```bash
$ kubectl scale statefulset web --replicas=1

$ kubectl scale statefulset web --replicas=3
```



# 18. Kubernetes服务质量

## 18.1 QoS原理与使用

### Lab58. Qos

> 节点资源

```bash
$ kubectl get node k8s-worker1 -o yaml | grep -A 13 allo
 `allocatable`:
    cpu: "2"
    ephemeral-storage: "36496716535"
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 3892256Ki
    pods: "110"
 `capacity`:
    cpu: "2"
    ephemeral-storage: 39601472Ki
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 3994656Ki
    pods: "110"
```

> Guaranteed

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: qos-demo
spec:
  containers:
  - name: qos-demo-ctr
    image: nginx
    resources:
      limits:
        memory: "200Mi"
        cpu: "700m"
      requests:
        memory: "200Mi"
        cpu: "700m"
EOF

```

```bash
$ kubectl get pod qos-demo -o yaml | grep qosC
  qosClass: `Guaranteed`
```

> Burstable

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: qos-demo-2
spec:
  containers:
  - name: qos-demo-2-ctr
    image: nginx
    resources:
      limits:
        memory: "200Mi"
      requests:
        memory: "100Mi"
EOF

```

```bash
$ kubectl get pod qos-demo-2 -o yaml | grep qosC
  qosClass: `Burstable`
```

> BestEffort

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: qos-demo-3
spec:
  containers:
  - name: qos-demo-3-ctr
    image: nginx
EOF

```

```bash
$ kubectl get pod qos-demo-3 -o yaml | grep qosC
  qosClass: `BestEffort`
```

> 超出容器的内存限制

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo
spec:
  containers:
  - name: memory-demo-ctr
    image: polinux/stress
    resources:
      limits:
        memory: "100Mi"
      requests:
        memory: "50Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
EOF

```

```bash
$ kubectl get pod memory-demo
NAME          READY   STATUS      RESTARTS   AGE
memory-demo   0/1    `OOMKilled`  0          20s
```

```bash
$ kubectl describe pod memory-demo | grep -A 2 Last
    Last State:     Terminated
      Reason:       OOMKilled
      Exit Code:    1
```

> 超出节点可用资源

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: memory-demo2
spec:
  containers:
  - name: memory-demo2-ctr
    image: polinux/stress
    resources:
      limits:
        memory: "1000Gi"
      requests:
        memory: "1000Gi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
EOF

```

```bash
$ kubectl get pod memory-demo2
NAME           READY   STATUS    RESTARTS   AGE
memory-demo2   0/1    `Pending`  0          22s
```

```bash
$ kubectl describe pod memory-demo2 | tail -n 1
  Warning  FailedScheduling  10s (x2 over 72s)  default-scheduler  0/3 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 2 Insufficient memory.
```



# 19. Kubernetes资源调度

## 19.1 k8s资源管理

```bash
$ kubectl get node k8s-worker1 -o yaml | grep -A 19 ^status
status:
  addresses:
  - address: 192.168.147.129
    type: InternalIP
  - address: k8s-worker1
    type: Hostname
  allocatable:
    cpu: "2"
    ephemeral-storage: "36496716535"
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 3892256Ki
    pods: "110"
  capacity:
    cpu: "2"
    ephemeral-storage: 39601472Ki
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 3994656Ki
    pods: "110" 
```

```bash
$ kubelet -h | grep eviction-hard.*map
      --eviction-hard mapStringString                            A set of eviction thresholds (e.g. memory.available<1Gi) that if met would trigger a pod eviction. (default imagefs.available<15%,memory.available<100Mi,nodefs.available<10%,nodefs.inodesFree<5%)
```

## 19.2 k8s调度器

## 19.3 k8s高度策略

## 19.4 k8s调度优先级和抢占机制

### Lab59. Priorityclass

```bash
$ kubectl get priorityclasses
NAME                      VALUE        GLOBAL-DEFAULT   AGE
system-cluster-critical   2000000000   false            34d
system-node-critical      2000001000   false            34d

$ kubectl describe priorityclasses system-cluster-critical
Name:           system-cluster-critical
Value:          2000000000
GlobalDefault:  false
Description:    Used for system critical pods that must run in the cluster, but can be moved to another node if necessary.
Annotations:    <none>
Events:         <none>

$ kubectl describe priorityclasses system-node-critical
Name:           system-node-critical
Value:          2000001000
GlobalDefault:  false
Description:    Used for system critical pods that must not be moved from their current node.
Annotations:    <none>
Events:         <none>
```

```yaml
kubectl apply -f- <<EOF
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:  
  name: high-priority
value: 1000000
globalDefault: false
EOF

```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  priorityClassName: high-priority
EOF

```

```bash
$ kubectl describe pod nginx | grep Priority
Priority:            `1000000`
Priority Class Name:  high-priority
```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-1
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
# priorityClassName: high-priority
EOF

```

```bash
$ kubectl describe pod nginx-1 | grep Pri
Priority:    `0`
```



# 20. Kubernetes Dashboard

## 20.1 Dashboard介绍

### Lab60. [部署 Dashboard UI](https://kubernetes.io/zh/docs/tasks/access-application-cluster/web-ui-dashboard/#%E9%83%A8%E7%BD%B2-dashboard-ui)

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
  <li> 国内默认无法访问 https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
  <li> gitee
</div>

> 1. 安装


```bash
$ kubectl apply -f https://gitee.com/suzhen99/k8s/raw/master/dashboard/v2.5.0/aio/deploy/recommended.yaml
`namespace`/kubernetes-dashboard created
`serviceaccount`/kubernetes-dashboard created
`service`/kubernetes-dashboard created
`secret`/kubernetes-dashboard-certs created
`secret`/kubernetes-dashboard-csrf created
`secret`/kubernetes-dashboard-key-holder created
`configmap`/kubernetes-dashboard-settings created
`role`.rbac.authorization.k8s.io/kubernetes-dashboard created
`clusterrole`.rbac.authorization.k8s.io/kubernetes-dashboard created
`rolebinding`.rbac.authorization.k8s.io/kubernetes-dashboard created
`clusterrolebinding`.rbac.authorization.k8s.io/kubernetes-dashboard created
`deployment.apps`/kubernetes-dashboard created
`service`/dashboard-metrics-scraper created
`deployment.apps`/dashboard-metrics-scraper created
```

```bash
$ kubectl -n kubernetes-dashboard get pods -owide
NAME                                         READY   STATUS    RESTARTS   AGE    IP              NODE          NOMINATED NODE   READINESS GATES
dashboard-metrics-scraper-799d786dbf-r7dp9   1/1     Running   0          115s   172.16.194.65   k8s-worker1   <none>           <none>
kubernetes-`dashboard`-546cbc58cd-2lvxt      1/1     Running   0          115s   172.16.126.1   `k8s-worker1`  <none>           <none>
```

> 2. 通过物理机访问

```bash
$ kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}' 

$ kubectl -n kubernetes-dashboard get svc
NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
dashboard-metrics-scraper   ClusterIP   10.103.222.187   <none>        8000/TCP        6m2s
kubernetes-dashboard       `NodePort`   10.97.233.31     <none>        443:`32433`/TCP   6m3s
```

> 3. 查看服务帐号kubernetes-dashboard的登陆 token

```bash
$ kubectl -n kubernetes-dashboard describe sa kubernetes-dashboard
...输出省略...
Mountable secrets:  `kubernetes-dashboard-token-chw6w`
Tokens:             `kubernetes-dashboard-token-chw6w`
Events:              <none>

$ kubectl -n kubernetes-dashboard describe secrets kubernetes-dashboard-token-chw6w
...输出省略...
Data
====
ca.crt:     1099 bytes
namespace:  20 bytes
token:      `eyJhbGciOiJSUzI1NiIsImtpZCI6Ik9HQ1B0N3Rxd1ZGRkhjaE01VGdveWJCLUg5UW9lenJ3VEtTMDFDVWFpWkUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC10b2tlbi1jaHc2dyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImVhYWMxNTc2LTk3YWMtNDI3NS1iNWRhLThlZWQ1NjYwYzkxMCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDprdWJlcm5ldGVzLWRhc2hib2FyZCJ9.PN4ViKOIw1RQLin_RN2CkmIeWcenaQNc6rdyNYLGAWk4E8UQcoyBQqsZ8SgOySqHzlFzWDpFJxRfSWjrEYimujfm2kuJ8lxlCu3-QsYKbuUEajLdNL99fIGh06bcCmEL_pp2kopCan4JawicKHYydZ8LV8gtVZ9YBKYHWkvYoJQ3r2uY77Oy_eUJX0GL-_ajPtiLBwKGfuFW1RrLDG2X6bRBhgZ7137pme1E5cEF1dxEuk1d-VEfieWctEXKbab5usS5vWBZDk2XEIDRNLCvBeF3yi2UWZq_F0LyCwCH_dHqCgk_WtccishjLG6fh6vJyOho_kLMx3jamZ8XarVKkA`
```

> 4. 提权

```bash
$ kubectl -n kubernetes-dashboard describe clusterrole cluster-admin
...输出省略...
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*]

$ kubectl -n kubernetes-dashboard \
describe clusterrole kubernetes-dashboard
...输出省略...
PolicyRule:
  Resources             Non-Resource URLs  Resource Names  Verbs
  ---------             -----------------  --------------  -----
  nodes.metrics.k8s.io  []                 []              [get list watch]
  pods.metrics.k8s.io   []                 []              [get list watch]

$ kubectl create clusterrolebinding kubernetes-dashboard-cluster-admin \
--clusterrole=cluster-admin \
--serviceaccount=kubernetes-dashboard:kubernetes-dashboard

$ kubectl get clusterrolebindings.rbac.authorization.k8s.io -owide | grep dash
kubernetes-dashboard-cluster-admin  ClusterRole/cluster-admin  6m34s  kubernetes-dashboard/kubernetes-dashboard
kubernetes-dashboard  ClusterRole/kubernetes-dashboard  88m  kubernetes-dashboard/kubernetes-dashboard
```

> 5. 登陆

![截屏2022-04-14 16.06.30](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-04-14%2016.06.30.png)

### Lab61. kubeconfig方式认证

```bash
$ kubectl -n kube-system create sa dashboard-admin

$ kubectl create clusterrolebinding dashboard-admin \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:dashboard-admin

$ SN=$(kubectl -n kube-system get secret | awk '/dashboard-admin/ {print $1}')

$ DASH_TOKEN=$(kubectl -n kube-system get secret ${SN} -o jsonpath={.data.token} | base64 -d)
```

> 创建 dashboard-admin.kubeconfig

```bash
$ kubectl config set-cluster ck8s \
--certificate-authority=/etc/kubernetes/pki/ca.crt \
--embed-certs=true \
--server=https://192.168.147.128:6443 \
--kubeconfig=dashboard-admin.kubeconfig

$ kubectl config set-context dashboard-admin@ck8s \
--cluster=ck8s \
--user=dashboard-admin \
--kubeconfig=dashboard-admin.kubeconfig

$ kubectl config set-credentials dashboard-admin \
--token=${DASH_TOKEN} \
--kubeconfig=dashboard-admin.kubeconfig

$ kubectl config use-context dashboard-admin@ck8s \
--kubeconfig=dashboard-admin.kubeconfig
```

```bash
$ vimdiff ~/.kube/config dashboard-admin.kubeconfig
```

物理机

```bash
$ scp kiosk@k8s-master:~/.kube/config .
$ scp kiosk@k8s-master:~/dashboard-admin.kubeconfig .
```

![截屏2022-05-24 18.23.24](https://gitee.com/suzhen99/k8s/raw/master/images/config.png)

## 20.2 Dashboard功能

## 20.3 Dashboard部署应用





# 21. Helm包管理工具

## 21.1 Helm简介

## 21.2 使用Helm

### Lab62. 安装、使用Helm

> [install helm](https://helm.sh/docs/intro/install/)

```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - \
&& sudo apt-get install apt-transport-https --yes \
&& echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
&& sudo apt-get update \
&& sudo apt-get install helm
```

> 使用Helm

```bash
$ helm version

$ helm search hub wordpress
```

```bash
$ helm repo add alirepo https://apphub.aliyuncs.com
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "alirepo" chart repository
Update Complete. ⎈Happy Helming!⎈

$ helm repo list
NAME   	URL
alirepo https://apphub.aliyuncs.com

$ helm search repo mysql
NAME                             	CHART VERSION	APP VERSION	DESCRIPTION
alirepo/mysql                    	6.8.0        	8.0.19     	Chart to create a Highly available MySQL cluster
...输出省略...
```

```bash
$ helm install alirepo/mysql --generate-name
```

```bash
$ helm list
NAME            	NAMESPACE	REVISIONUPDATED                                	STATUS  CHART      	APP VERSION
mysql-1653395570	default  	1       2022-05-24 12:32:51.008311838 +0000 UTC	deployedmysql-6.8.0	8.0.19
```

```bash
$ helm uninstall mysql-1653395570
```

## 21.3 Chart简介

### Lab63. Chart

```bash
$ ls ~/.cache/helm/repository

$ tar -xf ~/.cache/helm/repository/mysql-6.8.0.tgz

$ sudo apt install tree

$ tree mysql
mysql
├── Chart.yaml
├── ci
│   └── values-production.yaml
├── files
│   └── docker-entrypoint-initdb.d
│       └── README.md
├── README.md
├── templates
│   ├── _helpers.tpl
│   ├── initialization-configmap.yaml
│   ├── master-configmap.yaml
│   ├── master-statefulset.yaml
│   ├── master-svc.yaml
│   ├── NOTES.txt
│   ├── secrets.yaml
│   ├── servicemonitor.yaml
│   ├── slave-configmap.yaml
│   ├── slave-statefulset.yaml
│   └── slave-svc.yaml
├── values-production.yaml
└── values.yaml

4 directories, 17 files
```

## 21.4 Chart模板的使用

### Lab64. Helm部署mysql

> 1. 默认需要使用pv

```bash
$ helm inspect values alirepo/mysql | less
...
  persistence:
    enabled: true
    mountPath: /bitnami/mysql
    annotations: {}
    accessModes:
      - `ReadWriteOnce`
    size: `8Gi`
...
```

> 2. 创建pv

**[kiosk@192.168.147.128]**

```bash
sudo mkdir -m 777 /nfs_{a..b}
sudo tee /etc/exports <<EOF
/nfs_a *(rw,no_root_squash)
/nfs_b *(rw,no_root_squash)
EOF
sudo apt -y install nfs-kernel-server && \
sudo systemctl enable nfs-server && \
sudo systemctl restart nfs-server && \
showmount -e

```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pva
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs_a
    server: 192.168.147.128
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pvb
spec:
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs_b
    server: 192.168.147.128
EOF

```

```bash
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pva    8Gi        RWO            Recycle          Available                                   6s
pvb    8Gi        RWO            Recycle          Available
```

> 3. 安装mysql，并设置密码为 mima

```bash
$ helm install test alirepo/mysql --set root.password=mima

$ kubectl get pod -w
NAME                  READY   STATUS    RESTARTS   AGE
test-mysql-master-0  `1/1`    Running   0          2m35s
test-mysql-slave-0   `1/1`    Running   0          4m4s
<Ctrl-C>

$ helm list
NAME	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART      	APP VERSION
`test`	default  	1       	YYYY-MM-DD 13:49:58.731875229 +0000 UTC	deployed	mysql-6.8.0	8.0.19

$ helm status test
...输出省略...
Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace default

Services:

  echo Master: test-mysql.default.svc.cluster.local:3306
  echo Slave:  test-mysql-slave.default.svc.cluster.local:3306

Administrator credentials:

  echo Username: root
  echo Password : $(kubectl get secret --namespace default test-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)

To connect to your database:

  1. Run a pod that you can use as a client:

      kubectl run test-mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.19-debian-10-r0 --namespace default --command -- bash

  2. To connect to master service (read/write):

      mysql -h test-mysql.default.svc.cluster.local -uroot -p my_database

  3. To connect to slave service (read-only):

      mysql -h test-mysql-slave.default.svc.cluster.local -uroot -p my_database
...
```

> 4. 测试

```bash
$ kubectl get secret --namespace default test-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode
`mima`
```

```bash
$ kubectl run test-mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.19-debian-10-r0 --namespace default --command -- bash
```

```bash
I have no name!@test-mysql-client:/$ mysql -h test-mysql.default.svc.cluster.local -uroot -p my_database
Enter password: `mima`
mysql> exit
```

```bash
I have no name!@test-mysql-client:/$ mysql -h test-mysql-slave.default.svc.cluster.local -uroot -p my_database
Enter password: `mima`
mysql> exit
```

```bash
I have no name!@test-mysql-client:/$ exit
```



# 22. RBAC权限控制

## 22.1 k8s授权概述

### Lab65. Account

> 创建UserAccount

```bash
$ cd /etc/kubernetes/pki
$ sudo openssl genrsa -out tom.key
```

```bash
$ sudo openssl rand -writerand /root/.rnd

$ sudo openssl req \
-new \
-key tom.key \
-out tom.csr \
-subj "/CN=tom/O=kubeusers"
```

```bash
$ sudo openssl x509 \
-req \
-in tom.csr \
-CA ca.crt \
-CAkey ca.key \
-CAcreateserial \
-out tom.crt \
-days 365
```

```bash
$ kubectl config set-credentials tom \
  --client-certificate=tom.crt \
  --client-key=tom.key
```

```bash
$ kubectl config set-context tom@ck8s --cluster=ck8s --user=tom
```

> 切换身份

```bash
$ sudo chmod a+r tom.key

$ kubectl config use-context tom@ck8s
```

> 测试

```bash
$ kubectl get pods
error: unable to read client-key /etc/kubernetes/pki/tom.key for tom due to open /etc/kubernetes/pki/tom.key: permission denied

$ kubectl config use-context kubernetes-admin@ck8s
$ cd
```

> 创建ServiceAccount

```bash
$ kubectl create namespace mynamespace

$ kubectl create serviceaccount example-sa -n mynamespace
```

```bash
$ kubectl create deployment d1 --image=nginx --replicas=3

$ kubectl get pods
NAME                  READY   STATUS              RESTARTS   AGE
d1-68d57c4c7f-lbxp8   0/1     ContainerCreating   0          6s
d1-68d57c4c7f-lphcz   0/1     ContainerCreating   0          6s
d1-68d57c4c7f-m4699   0/1     ContainerCreating   0          6s

$ kubectl get pods d1-68d57c4c7f-lbxp8 -o yaml | grep serviceAccountName
  serviceAccountName: `default`
  
$ kubectl describe pods d1-68d57c4c7f-lbxp8
```

```bash
$ kubectl -n mynamespace get sa
NAME         SECRETS   AGE
`default`    1         11m
example-sa   1         10m

$ kubectl -n mynamespace describe sa default | grep Tokens
Tokens:             `default-token-djfrr`

$ kubectl -n mynamespace get secrets
NAME                     TYPE                                  DATA   AGE
`default-token-djfrr`    kubernetes.io/service-account-token   3      12m
example-sa-token-qcdvj   kubernetes.io/service-account-token   3      12m
```



## 22.2 RBAC插件简介

### Lab66. RBAC插件

> RBAC中的对象-role

```bash
$ kubectl create role example-role \
  --verb="get,watch,list" \
  --resource="pods" \
  -n mynamespace
```

> RBAC中的对象-ClusterRole

```bash
$ kubectl create clusterrole example-clusterrole \
  --verb="get,watch,list" \
  --resource="pods"
```

> RBAC中的对象- RoleBinding

```bash
$ kubectl create rolebinding example-rolebinding \
  --role=example-role \
  --user=user1
  -n mynamespace
```

> RBAC中的对象- ClusterRoleBinding

```bash
$ kubectl create clusterrolebinding example-clusterrolebinding \
  --clusterrole=example-clusterrole \
  --user=user1
```

> 内置ClusterRole和ClusterRolebinding

```bash
$ kubectl get clusterroles
```

```bash
$ kubectl describe clusterrole cluster-admin
Name:         cluster-admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*]
```



# 23. Kubernetes日志管理方案

## 23.1 k8s日志管理

```bash
$ sudo cat /var/log/pods/kube-system_kube-apiserver-k8s-master_cc2b4b37dd11e738628e66eb6e8039d6/kube-apiserver/0.log


$ sudo apt -y install jq

$ sudo cat /var/log/pods/kube-system_kube-apiserver-k8s-master_cc2b4b37dd11e738628e66eb6e8039d6/kube-apiserver/0.log | jq
```



## 23.2 EFK日志管理

### Lab67. [开始使用Elastic Stack](https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-elastic-stack.html#get-started-elastic-stack)

> 0a. 安装 helm

```bash
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - \
&& sudo apt-get install apt-transport-https --yes \
&& echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
&& sudo apt-get update \
&& sudo apt-get install helm

```


> 0b. 配置 elastic 仓库

```bash
$ helm repo add elastic https://helm.elastic.co && \
helm repo add fluent https://fluent.github.io/helm-charts && \
helm search repo
NAME                     	CHART VERSION	APP VERSION	DESCRIPTION
elastic/`elasticsearch`   7.17.3       	7.17.3     	Official Elastic helm chart for Elasticsearch
elastic/`kibana`          7.17.3       	7.17.3     	Official Elastic helm chart for Kibana
fluent/`fluent-bit`      	0.20.1       	1.9.3      	Fast and lightweight log processor and forwarde...
fluent/fluentd           	0.3.7        	v1.12.4    	A Helm chart for Kubernetes
...输出省略...
```

> 1. 安装 Elasticsearch
>    分布式 RESTful 搜索和分析引擎

```bash
$ helm inspect values elastic/elasticsearch | less
...输出省略...
replicas: `3`
minimumMasterNodes: `2`
...
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
...
volumeClaimTemplate:
  accessModes: `["ReadWriteOnce"]`
  resources:
    requests:
      storage: `30Gi`
...
persistence:
  enabled: `true`
...
```

**[root@192.168.147.128]**

```bash
sudo apt -y install nfs-kernel-server && \
sudo mkdir -m 777 /nfs_log{0..1} && \
sudo tee /etc/exports <<EOF
/nfs_log0 *(rw,no_root_squash)
/nfs_log1 *(rw,no_root_squash)
EOF

sudo systemctl restart nfs-server && \
showmount -e

```

```yaml
kubectl apply -f- <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log0
spec:
  capacity:
    storage: 30Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs_log0
    server: 192.168.147.128
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log1
spec:
  capacity:
    storage: 30Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /nfs_log1
    server: 192.168.147.128
EOF

```

```bash
$ helm install elasticsearch elastic/elasticsearch --set replicas=2,minimumMasterNodes=1,image="registry.cn-hangzhou.aliyuncs.com/k-cka/elasticsearch"
...
NOTES:
1. Watch all cluster members come up.
  $ kubectl get pods --namespace=default -l app=elasticsearch-master -w
2. Test cluster health using Helm test.
  $ helm --namespace=default test elasticsearch
```

```bash
$ kubectl get pods --namespace=default -l app=elasticsearch-master -w
NAME                     READY   STATUS     RESTARTS   AGE
elasticsearch-master-0   0/1     Init:0/1   0          19s
elasticsearch-master-1   0/1     Init:0/1   0          19s
elasticsearch-master-1   0/1     PodInitializing   0          2m13s
elasticsearch-master-0   0/1     PodInitializing   0          2m15s
elasticsearch-master-1   0/1     Running           0          2m15s
elasticsearch-master-0   0/1     Running           0          2m18s
elasticsearch-master-1  `1/1`    Running           0          5m33s
elasticsearch-master-0  `1/1`    Running           0          5m33s
<Ctrl-C>
```

```bash
$ helm --namespace=default test elasticsearch
...输出省略...
Phase:         `Succeeded`
```

> 2. fluent-bit
>    快速轻量级日志处理器和转发器

```bash
$ helm install fluent-bit fluent/fluent-bit
...输出省略...
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace default port-forward $POD_NAME 2020:2020
curl http://127.0.0.1:2020


$ export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}") && \
echo $POD_NAME && \
kubectl get pods $POD_NAME -w
NAME               READY   STATUS              RESTARTS   AGE
fluent-bit-4dg4h   0/1     ContainerCreating   0          13s
fluent-bit-4dg4h   0/1     Running             0          2m26s
fluent-bit-4dg4h  `1/1`    Running             0          2m26s
<Ctrl-C>

$ kubectl --namespace default port-forward $POD_NAME 2020:2020

$ curl http://127.0.0.1:2020
{"fluent-bit":{"version":"1.9.3","edition":"Community","flags":["FLB_HAVE_IN_STORAGE_BACKLOG","FLB_HAVE_PARSER","FLB_HAVE_RECORD_ACCESSOR","FLB_HAVE_STREAM_PROCESSOR","FLB_HAVE_TLS","FLB_HAVE_OPENSSL","FLB_HAVE_METRICS","FLB_HAVE_AWS","FLB_HAVE_AWS_CREDENTIAL_PROCESS","FLB_HAVE_SIGNV4","FLB_HAVE_SQLDB","FLB_HAVE_METRICS","FLB_HAVE_HTTP_SERVER","FLB_HAVE_SYSTEMD","FLB_HAVE_FORK","FLB_HAVE_TIMESPEC_GET","FLB_HAVE_GMTOFF","FLB_HAVE_UNIX_SOCKET","FLB_HAVE_LIBYAML","FLB_HAVE_ATTRIBUTE_ALLOC_SIZE","FLB_HAVE_PROXY_GO","FLB_HAVE_JEMALLOC","FLB_HAVE_LIBBACKTRACE","FLB_HAVE_REGEX","FLB_HAVE_UTF8_ENCODER","FLB_HAVE_LUAJIT","FLB_HAVE_C_TLS","FLB_HAVE_ACCEPT4","FLB_HAVE_INOTIFY","FLB_HAVE_GETENTROPY","FLB_HAVE_GETENTROPY_SYS_RANDOM"]}}

$ kubectl edit configmap fluent-bit
Edit cancelled, no changes made.
```

> 3. 安装 Kibana
>    用于 Elasticsearch 的基于浏览器的分析和搜索仪表板

```bash
$ helm inspect values elastic/kibana | less
...输出省略...
resources:
  requests:
    cpu: "1000m"
    memory: "2Gi"
  limits:
    cpu: "1000m"
    memory: "2Gi"
...输出省略...  
service:
  type: `ClusterIP`
...输出省略...  
image: "docker.elastic.co/kibana/kibana"

* master 节点参与 POD 负载,默认不参与
$ kubectl taint nodes k8s-master node-role.kubernetes.io/master-
node/k8s-master untainted

$ helm install kibana elastic/kibana --set service.type=NodePort,image="registry.cn-hangzhou.aliyuncs.com/k-cka/kibana"
```

```bash
$ kubectl get pod -l app=kibana -w
NAME                             READY   STATUS    RESTARTS   AGE
kibana-kibana-85d5f98b79-z24p5   0/1     ContainerCreating   0          20s
kibana-kibana-85d5f98b79-z24p5   0/1     ContainerCreating   0          29s
kibana-kibana-85d5f98b79-z24p5   0/1     Running             0          7m51s
kibana-kibana-85d5f98b79-z24p5  `1/1`    Running             0          10m
<Ctrl-C>
```

> 4. 配置Kibana

```bash
$ kubectl get pod -owide
 -l app=kibana
NAME                             READY   STATUS    RESTARTS   AGE    IP               NODE         NOMINATED NODE   READINESS GATES
kibana-kibana-85d5f98b79-4vpqw   1/1     Running   0          7m5s   172.16.235.200  `k8s-master`  <none>           <none>

$ kubectl get svc kibana-kibana
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kibana-kibana   NodePort   10.99.144.226   <none>        5601:`31702`/TCP   7m50s
```

物理机浏览器 http://k8s-master:31702

- 点击<kbd>Exlore on my own</kbd>

![截屏2022-05-30 14.56.33](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2014.56.33.png)

- 点击<kbd>Stack Management</kbd>

![截屏2022-05-26 16.15.25](https://gitee.com/suzhen99/k8s/raw/master/images/elastic1.png)

<img src='https://gitee.com/suzhen99/k8s/raw/master/images/n.png' height=30>==Open side navigation== / **Kibana** / <kbd>Index Patterns</kbd>

![截屏2022-05-26 16.22.46](https://gitee.com/suzhen99/k8s/raw/master/images/elastic2.png)

- 点击<kbd>Create index pattern</kbd>

![截屏2022-05-26 16.28.21](https://gitee.com/suzhen99/k8s/raw/master/images/elastic1628.png)

- Name：==log*==, Tmestamp field ==@timestamp==, <kbd>Create index pattern</kbd>

![截屏2022-05-26 18.26.37](https://gitee.com/suzhen99/k8s/raw/master/images/elastic1826.png)

- <img src='https://gitee.com/suzhen99/k8s/raw/master/images/m.png' height=30> /  **Analytics**/ <kbd>Discover</kbd>

![截屏2022-05-26 16.34.59](https://gitee.com/suzhen99/k8s/raw/master/images/elastic1635.png)

> 6. 创建测试容器

```bash
$ kubectl run busybox --image=busybox --image-pull-policy=IfNotPresent -- sh -c 'while true; do echo "This is a log message from container busybox!"; sleep 5; done;' && \
kubectl get pod busybox -w
NAME      READY   STATUS              RESTARTS   AGE
busybox   0/1     ContainerCreating   0          1s
busybox   0/1     ContainerCreating   0          7s
busybox  `1/1`    Running             0          29s
<Ctrl-C>
```

> 7. 查看日志（稍等片刻）

![截屏2022-05-26 18.57.52](https://gitee.com/suzhen99/k8s/raw/master/images/elastic1857.png)



# 24. Kubernetes监控方案

## 24.1 k8s常用监控方案

## 24.2 Prometheus概述

### Lab68. [Kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)

#### 1. 安装<img height=30 src='https://avatars.githubusercontent.com/u/66682517?s=200&v=4'>

 https://github.com/prometheus-operator

```bash
$ git clone https://github.com/prometheus-operator/kube-prometheus.git
Cloning into 'kube-prometheus'...
remote: Enumerating objects: 16183, done.
remote: Counting objects: 100% (104/104), done.
remote: Compressing objects: 100% (60/60), done.
remote: Total 16183 (delta 57), reused 78 (delta 39), pack-reused 16079
Receiving objects: 100% (16183/16183), 8.08 MiB | 28.00 KiB/s, done.
Resolving deltas: 100% (10397/10397), done.

$ cd kube-prometheus
$ git checkout release-0.10

$ kubectl apply -f manifests/setup
...输出省略...
namespace/monitoring created
The CustomResourceDefinition "prometheuses.monitoring.coreos.com" is `invalid`: metadata.annotations: Too long: must have at most 262144 bytes

$ kubectl create -f manifests/setup/0prometheusCustomResourceDefinition.yaml

$ kubectl apply -f manifests
```

> 国内有些镜像拉不下来，需要单独处理

```bash
$ kubectl -n monitoring get pods | grep -v Running
NAME                                   READY   STATUS             RESTARTS         AGE
`blackbox-exporter-6b79c4588b-m9255`   1/3     ImagePullBackOff   5 (28s ago)      11m
`kube-state-metrics-55f67795cd-7644m`  0/3     CrashLoopBackOff   12 (2m51s ago)   11m
`prometheus-adapter-85664b6b74-7vn4b`  0/1     CrashLoopBackOff   7 (26s ago)      11m
`prometheus-operator-6dc9f66cb7-2qbf6` 0/2     CrashLoopBackOff   12 (102s ago)    11m
```

- blackbox-exporter:v0.19.0

```bash
$ kubectl -n monitoring describe pod blackbox-exporter-6b79c4588b-m9255
  Normal   Pulling    8m51s (x2 over 12m)    kubelet            Pulling image "quay.io/prometheus/blackbox-exporter:v0.19.0"
  
$ for i in k8s-master k8s-worker1 k8s-worker2; do ssh $i "
sudo docker pull registry.cn-hangzhou.aliyuncs.com/k-cka/blackbox-exporter:v0.19.0
sudo docker tag registry.cn-hangzhou.aliyuncs.com/k-cka/blackbox-exporter:v0.19.0 quay.io/prometheus/blackbox-exporter:v0.19.0
"; done
```

- kube-state-metrics:v2.3.0

```bash
$ kubectl -n monitoring describe pod kube-state-metrics-55f67795cd-7644m
  Normal   BackOff    39s (x101 over 18m)  kubelet            Back-off pulling image "k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0"
  
$ for i in k8s-master k8s-worker1 k8s-worker2; do ssh $i "
sudo docker pull registry.cn-hangzhou.aliyuncs.com/k-cka/kube-state-metrics:v2.3.0
sudo docker tag registry.cn-hangzhou.aliyuncs.com/k-cka/kube-state-metrics:v2.3.0 k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0
"; done
```

- prometheus-adapter:v0.9.1

```bash
$ kubectl -n monitoring describe pod prometheus-adapter-85664b6b74-7vn4b
  Normal   Pulled     21m (x5 over 23m)     kubelet            Container image "k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.1" already present on machine
  
$ for i in k8s-master k8s-worker1 k8s-worker2; do ssh $i "
sudo docker pull registry.cn-hangzhou.aliyuncs.com/k-cka/prometheus-adapter:v0.9.1
sudo docker tag registry.cn-hangzhou.aliyuncs.com/k-cka/prometheus-adapter:v0.9.1 k8s.gcr.io/prometheus-adapter/prometheus-adapter:v0.9.1
"; done
```

- prometheus-operator:v0.53.1

```bash
$ kubectl -n monitoring describe pod prometheus-operator-6dc9f66cb7-2qbf6
  Normal   Pulled     20m (x2 over 21m)     kubelet            Container image "quay.io/prometheus-operator/prometheus-operator:v0.53.1" already present on machine
  
$ for i in k8s-master k8s-worker1 k8s-worker2; do ssh $i "
sudo docker pull registry.cn-hangzhou.aliyuncs.com/k-cka/prometheus-operator:v0.53.1
sudo docker tag registry.cn-hangzhou.aliyuncs.com/k-cka/prometheus-operator:v0.53.1 quay.io/prometheus-operator/prometheus-operator:v0.53.1
"; done
```

```bash
$ kubectl -n monitoring  get pods
```



```bash
$ kubectl -n monitoring patch svc grafana -p '{"spec":{"type":"NodePort"}}' 
$ kubectl -n monitoring patch svc prometheus-k8s -p '{"spec":{"type":"NodePort"}}' 

$ kubectl -n monitoring get svc | egrep 'grafana|prometheus-k8s'
grafana         NodePort  10.104.141.103  <none>  3000:`30214`/TCP                 13m
prometheus-k8s  NodePort  10.96.106.1     <none>  9090:`31721`/TCP,8080:32201/TCP  13m

$ kubectl -n monitoring get pod -owide | egrep 'grafana|prometheus-k8s'
grafana-7fd69887fb-r6f4x  1/1  Running  0  13m  172.16.126.1     `k8s-worker2`  <none>  <none>
prometheus-k8s-0					2/2  Running  0  17m  172.16.194.70    `k8s-worker1`  <none>  <none>
prometheus-k8s-1					2/2  Running  0  17m  172.16.126.5     `k8s-worker2`  <none>  <none>
```

#### 2. 配置prometheus

- 物理机 http://k8s-worker1:31721

![截屏2022-05-30 21.42.21](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2021.42.21.png)

- 点击菜单 <kbd>Status</kbd> / <kbd>Targets</kbd> ，确认所有的 State 都是 ==UP==（能够正常获取监控数据）

![截屏2022-05-30 21.45.04](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2021.45.04.png)

#### 3. 配置grafana

- 物理机http://k8s-worker2:30214

> Email or username ==admin== 
> Password ==admin==

![g1o](https://gitee.com/suzhen99/k8s/raw/master/images/g1o.png)

#### 4. 配置数据源

> 默认安装已经配置好了数据源

![截屏2022-05-30 21.54.18](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2021.54.18.png)

#### 5. 添加Dashboard模版

>  https://grafana.com/grafana/dashboards

<kbd>Filter</kbd>，Category: ==Docker==， Data Source：==Prometheus==

![截屏2022-05-30 21.59.08](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2021.59.08.png)

- 点击 ==1 Node Exporter for Prometheus Dashboard EN v20201010==

![截屏2022-05-30 22.01.02](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2022.01.02.png)

- <kbd>Copy ID to Clipboard</kbd>

![截屏2022-05-30 22.04.47](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2022.04.47.png)

- 物理机 http://k8s-worker2:30214
  <kbd>Create</kbd> / <kbd>Import</kbd>

![截屏2022-05-30 22.08.55](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2022.08.55.png)

- Import via grafana.com ==11074==，<kbd>Load</kbd>

![截屏2022-05-30 22.09.26](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2022.09.26.png)

- VictoriaMetrics 下拉菜单中选择 ==Prometheus==，<kbd>Import</kbd>

![截屏2022-05-30 22.10.38](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-05-30%2022.10.38.png) 

![g2218](https://gitee.com/suzhen99/k8s/raw/master/images/g2218.png)






# 附录

## A1. 学习方法

| step |                |                    | 示例                                                         |
| :--: | :------------: | ------------------ | ------------------------------------------------------------ |
|  1   |      word      | 查单词，释义       | pull, 拉                                                     |
|  2   | <kbd>Tab</kbd> | 一下补全，两下列出 | # doc<kbd>Tab</kbd><br># docker <kbd>Tab</kbd>, <kbd>Tab</kbd><kbd>Tab</kbd> |
|  3   |  man, --help   | 帮助               | # man docker<br># docker --help                              |
|  4   |    echo \$?    | 查看回显           | 0 == 正确执行<br>非0 == 错误执行                             |

```bash
# docker --help
```

```bash
# man docker run
```

|  ID  |                              |         说明          |
| :--: | :--------------------------: | :-------------------: |
|  1   |         <kbd>f</kbd>         |      For.. 前进       |
|  2   |         <kbd>b</kbd>         |       Back 后退       |
|  3   |             /-d              |      搜索==-d==       |
|  4   | <kbd>n</kbd> \| <kbd>N</kbd> | Next 下一个 \| 上一个 |
|  5   |         <kbd>q</kbd>         |       Quit 退出       |



## A2. 培训相关软件

|      |                             NAME                             |            URL            |       FUNC        |
| :--: | :----------------------------------------------------------: | :-----------------------: | :---------------: |
|  1   |                           欧路词典                           |       www.eudic.net       |     翻译软件      |
|  2   |                            Typora                            |    https://typoraio.cn    | MarkDown 格式文档 |
|  3   |                            VMware                            | https://www.vmware.com/cn |    虚拟化软件     |
|  4   | [Ubuntu](https://mirrors.dgut.edu.cn/ubuntu-releases/20.04.4/ubuntu-20.04.4-desktop-amd64.iso) |    https://ubuntu.com     |   系统光盘 iso    |

## A3. terminal-shortcut

|      |                                                              |                  |
| :--: | :----------------------------------------------------------: | ---------------- |
|  1   | <kbd>Ctrl</kbd>-<kbd>+</kbd> \| <kbd>Ctrl</kbd>-<kbd>Shift</kbd>-<kbd>=</kbd> | 放大字体         |
|  2   |        <kbd>Ctrl</kbd>-<kbd>Shift</kbd>-<kbd>T</kbd>         | 新建标签         |
|  3   |  <kbd>Alt</kbd>-<kbd>1</kbd> \| <kbd>Alt</kbd>-<kbd>2</kbd>  | 终端1、2之间切换 |
|      |                                                              |                  |

## A4. vim

| mode |              |                | 状态栏       |                     |
| :--: | :----------: | -------------- | ------------ | ------------------- |
|  1   | **命令模式** | <kbd>i</kbd>   |              | 默认工作模式        |
|  2   |   输入模式   | <kbd>Esc</kbd> | -- INSERT -- | 退出输入模式        |
|  3   |   末行模式   | :wq!           |              | write quit 保存退出 |

```bash
使用命令，未安装提示安装方法
$ vim

Command 'vim' not found, but can be installed with:

`sudo apt install vim`       # version 2:8.1.2269-1ubuntu5.7, or
sudo apt install vim-tiny    # version 2:8.1.2269-1ubuntu5.7
sudo apt install neovim      # version 0.4.3-3
sudo apt install vim-athena  # version 2:8.1.2269-1ubuntu5.7
sudo apt install vim-gtk3    # version 2:8.1.2269-1ubuntu5.7
sudo apt install vim-nox     # version 2:8.1.2269-1ubuntu5.7

按照提示安装
$ sudo apt install vim
[sudo] password for kiosk: `ubuntu`
```

```bash
$ vim my.txt
<i>
ni hao
<Esc>
:wq!
```

## A5. ssh-server

**[Server/虚拟机]**

```bash
通过关键字，查找安装包名称
$ apt search ssh | grep server

安装
$ sudo apt install openssh-server

确认服务器地址
$ ip a | grep -w inet
    inet 127.0.0.1/8 scope host lo
    inet `192.168.73.137/24` brd 192.168.73.255 scope global dynamic noprefixroute ens33
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

**[Client/物理机]**

```bash
% ssh kiosk@192.168.73.137
kiosk@192.168.73.137\'s password: `ubuntu`
$ 
```

## A6. 搭建培训环境

> 手册：https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
>
> 机器：
>
> ​		**虚拟机/VMware*3**
>
> ​		物理机*3，公司
>
> ​		云主机*3（阿里云、腾讯云、华为云）

- <a href='#Lab23'>lab23</a>

- <a href='#Lab24'>lab24</a>

## A7. 培训环境转成练习环境

> 接近考试环境，可以做练习题

## A8. apt

```bash
$ ip a

$ ip route

$ sudo apt search apt-file
$ sudo apt install apt-file -y

$ sudo apt-file update
$ apt-file search bin/ping

$ apt show inetutils-ping
$ apt show iputils-ping

$ sudo apt install -y inetutils-ping
$ ping 8.8.8.8

$ apt-file search bin/host
$ sudo apt install -y bind9-host
$ host www.163.com
$ host www.163.com 8.8.8.8
```

