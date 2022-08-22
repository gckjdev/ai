[TOC]

# 1. 准备工作

## 1.1 证书详情

> https://training.linuxfoundation.cn/certificate/details/1

**注意事项:**

1. 注册账号，填写公司发票或者个人发票
2. 付款后需要实名认证，实名认证的时间在一个天左右
3. 考试报名，推荐名称写英文，比如: `Zhen Su` ，考试需要检查`护照` 。
   (写中文名字，需要准备：`身份证`+`VISA信用卡`或`身份证`+`国际驾照`，两个卡需要有签名)
4. 考前检查工作: 
   - [x] Chrome 浏览器是设置为允许所有 Cookie
   - [x] 安装 PSI Google Chrome Extension (科学上网才能安装)
   - [x] 检查网络(下载电影，速度2M)
5. 预约考试时间：提前`3`天预约，如果预约考试成功但是没有准备准时参加考试，取消考试资格 与补考资格。(下次考试在2088)
6. 考试当天提前`20`分钟登陆考试页面，等待考官

## 1.2 考试注意事项

1. 在浏览器上方，共享桌面和摄像头(确保考试电脑麦克风、摄像头是正常的)，将自己的电脑静音。
2. 关闭Chrome浏览器以外的应用程序
3. 检查你的房间(1. 中途不能有人进出 2. 房间的墙不能是透明的 3. 背景不能是窗户 4. 房间不能有人 5. 检查你考试的桌子，不能有电子产品)
4. 检查你的手腕，不能有电子产品
5. 考试中途可以提休息申请，计算在2个小时范围内
6. 考试只允许使用Web页面上的考试控制--记事本
7. 考试没有复制粘贴快捷键，鼠标右键
8. 考试中途请闭嘴
9. 考试中间头部正对摄像头
10. 考试中途，考官会不定时的让你举起双手
11. 考试允许访问kubernetes.io的网站，在官网上的链接可能会跳转到其他网站，尽量避免二次跳转
12. 考试过程中，Chrome浏览器最多打开两个标签页
13. MacBook提前修改下『安全性与隐私』。屏幕录制中添加`Google Chrome`，这个操作需要关闭应用重新打开



# 2. 考试说明

## 2.1 考试环境

- 此考试中的每项任务都必须在指定的集群/配置上下文中完成。
- 为了最小化切换，任务被分组以便给定集群上的所有问题连续出现。（==实际并没有连续显示==）
- 考试环境由七个集群组成，由不同数量的容器组成，如下所示：

**CKA Clusters**

| Cluster |       Members        |              练习环境 节点               |
| :-----: | :------------------: | :--------------------------------------: |
|    -    |       console        |                  物理机                  |
|   k8s   | 1 master<br>2 worker |  k8s-master<br>k8-worker1, k8s-worker2   |
|  ek8s   | 1 master<br>2 worker | ek8s-master<br>ek8-worker1, ek8s-worker2 |

- 在每个任务开始时，您将收到命令以确保您在正确的集群上完成任务。
- 可以使用如下命令通过 ssh 访问组成每个集群的节点：==ssh \<nodename>==。 
- 您可以通过发出以下命令在任何节点上获得提升的权限：==sudo -i==。
- 您还可以随时使用 sudo 以提升的权限执行命令。
- 完成每项任务后，您必须返回基本节点（主机名 node-1）。
- 不支持嵌套的 ssh。
- 您可以使用 kubectl 和适当的上下文从基本节点处理任何集群。当通过 ssh 连接到集群成员时，您将只能通过 kubectl 在该特定集群上工作。
- 为方便起见，所有环境，即基本系统和集群节点，都预安装和预配置了以下附加命令行工具：
  - `kubectl`带有别名`k`和 Bash 自动完成功能
  - `jq `用于 YAML/JSON 处理
  - `tmux` 用于终端复用
  - `curl`并用于测试 Web 服务`wget`
  - `man` 和手册页以获取更多文档
- 将在适当的任务中提供有关连接到集群节点的进一步说明。
- ==如果未指定显式命名空间，则应使用默认命名空间。==
- 如果您需要销毁/重新创建资源以执行特定任务，您有责任在销毁资源之前适当地备份资源定义。
- CKA 和 CKAD 环境当前运行 Kubernetes v1.23.2。 *在 K8s 发布日期的大约 4 到 8 周内，CKA、CKS 和 CKAD 考试环境将与最新的 K8s 次要版本保持一致。*

## 2.2 考试期间允许的资源

在考试期间，考生可以：

- 查看命令行终端中显示的考试内容说明

- 查看发行版安装的文件（即 /usr/share 及其子目录）

- 使用其Chrome和Chromium浏览器中打开一个附加选项卡，以获取资产：https://kubernetes.io/docs/，https://github.com/kubernetes/，   https://kubernetes.io/blog/和他们的子域。这包括这些页面的所有可用的语言翻译（如[https://kubernetes.io/zh/docs/）](https://kubernetes.io/zh/docs/home/)

  ![chrome](https://gitee.com/suzhen99/k8s/raw/master/images/chrome-logo.png) `下载书签，并导入`

  ```html
  https://gitee.com/suzhen99/k8s/blob/master/Bookmarks/CKA-Bookmark.html
  https://www.examslocal.com/linuxfoundation
  ```

- 不能打开其他选项卡，也不能导航到其他站点（包括https://discuss.kubernetes.io/）。

- 上述允许的站点可能包含指向外部站点的链接。考生有责任不点击任何导致他们导航到不允许的域的链接。

## 2.3 考试技术说明

1. 可以通过运行 `sudo -i`获得 root 权限

2. 任何时候都允许重新启动您的服务器

3. 不要停止或篡改 certerminal 进程，因为这将结束您的考试

4. 不要阻止传入端口 8080/tcp、4505/tcp 和 4506/tcp。这包括在发行版的默认防火墙配置文件中找到的防火墙规则以及交互式防火墙命令

5. 使用 <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>W</kbd> 代替 <kbd>Ctrl</kbd>+<kbd>W</kbd>

   5.1 <kbd>Ctrl</kbd>+<kbd>W</kbd> 是一个键盘快捷键，用于关闭谷歌浏览器中的当前选项卡

6. 您的考试终端不支持 <kbd>Ctrl</kbd>+<kbd>C</kbd> 和 <kbd>Ctrl</kbd>+<kbd>V</kbd>。 要复制和粘贴文本，请使用；

   6.1 Linux：选择文本进行复制和中键进行粘贴（如果没有中键，则可以同时选择左右键）

   6.2 Mac：<kbd>⌘</kbd>+<kbd>C</kbd> 复制，<kbd>⌘</kbd>+<kbd>V</kbd> 粘贴

   6.3 ==**Windows：<kbd>Ctrl</kbd>+<kbd>Insert</kbd> 复制，<kbd>Shift</kbd>+<kbd>Insert</kbd> 粘贴**==

   6.4 此外，您可能会发现在粘贴到命令行之前使用记事本（参见“考试控制”下的顶部菜单）操作文本会很有帮助

7. 此考试中包含的服务和应用程序的安装可能需要修改系统安全策略才能成功完成

8. 考试期间只有一个终端控制台可用。GNU Screen 和 tmux 等终端多路复用器可用于创建虚拟控制台

## 2.4 可接受的测试地点

以下是对可接受的测试地点的期望：

- **整洁的工作区**
  - 表面上没有纸、书写工具、电子设备或其他物体等物体
  - 测试表面下方无纸、垃圾桶或其他物体等物体
- **干净的墙壁**
  - 墙上没有纸/打印件
  - 绘画和其他墙壁装饰是可以接受的
  - 考生将被要求在考试开始前移除非装饰物品
- **灯光**
  - 空间必须光线充足，以便监考人员能够看到考生的脸、手和周围的工作区域
  - 考生身后没有明亮的灯光或窗户
- **其他**
  - 考生在考试期间必须保持在相机范围内
  - 空间必须是私密的，没有过多的噪音。不允许进入咖啡店、商店、开放式办公环境等公共场所。

有关考试期间政策、程序和规则的更多信息，请参阅[考生手册]

## 2.5 其他资源

如果您需要其他帮助，请使用您的 LF 帐户登录  [https://trainingsupport.linuxfoundation.org](https://trainingsupport.linuxfoundation.org/) 并使用搜索栏查找问题的答案，或从提供的类别中选择您的请求类型



## 2.A 考试小提示

- 配置补全

  ```bash
  $ echo 'source <(kubectl completion bash)' >> ~/.bashrc
  ```

- 注意在哪个`集群`操作的

- 注意在哪个`节点`操作的

- 注意在哪个`ns`操作的



# 3. 练习题

Task 1. RBAC - role based access control（4/25%）

Task weight: 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Context:**
>
> You have been asked to create a new `ClusterRole` for a deployment pipeline and bind it to a specific `ServiceAccount` scoped to a specific namespace.
>
> **Task:**
>
> - [ ] Create a new ClusterRole named` deployment-clusterrole`, which only allows to create the following resource types:
>    - `Deployment`
>     - `StatefulSet`
>    - `DaemonSet`
>
> - [ ] Create a new `ServiceAccount` named `cicd-token` in the existing namespace `app-team1`
>
> - [ ] bind the new ClusterRole `deployment-clusterrole` to the new Service Account `cicd-token`, limited to the namespace `app-team1`

> **内容：**
>
> 为部署管道创建一个新的 `ClusterRole` 并将其绑定到范围为特定 namespace 的特定 `ServiceAccount`
>
> **任务：**
>
> - [ ] 创建一个名字为 `deployment-clusterrole` 且仅允许创建以下资源类型的新 `ClusterRole`：
>   - `Deployment`
>   - `StatefulSet`
>   - `DaemonSet`
> - [ ] 在现有的 namespace `app-team1` 中创建一个名为 `cicd-token` 的新 `ServiceAccount`。
> - [ ] 限于 namespace `app-team1` ，将新的 ClusterRole `deployment-clusterrole` 绑定到新的 ServiceAccount `cicd-token`。

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 创建 ClusterRole（资源名后面的 s 可以不加）

```bash
$ kubectl create clusterrole --help

*$ kubectl create clusterrole deployment-clusterrole \
  --verb=create \
  --resource=Deployment,StatefulSet,DaemonSet
```

3. 创建 serviceaccount

```bash
*$ kubectl --namespace app-team1 create serviceaccount cicd-token
```

4. 绑定 rolebinding

```bash
$ kubectl create rolebinding --help

*$ kubectl create rolebinding cicd-token-deployment-clusterrole \
  --clusterrole=deployment-clusterrole \
  --serviceaccount=app-team1:cicd-token \
  --namespace=app-team1
```

5. 验证

```bash
$ kubectl describe clusterrole deployment-clusterrole
Name:         deployment-clusterrole
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources          Non-Resource URLs  Resource Names  Verbs
  ---------          -----------------  --------------  -----
  daemonsets.apps    []                 []              [create]
  deployments.apps   []                 []              [create]
  statefulsets.apps  []                 []              [create]
  
$ kubectl -n app-team1 get serviceaccounts
NAME         SECRETS   AGE
`cicd-token` 1         16m
default      1         18m

$ kubectl -n app-team1 get rolebindings
NAME                                ROLE                                 AGE
cicd-token-deployment-clusterrole   ClusterRole/deployment-clusterrole   11m

$ kubectl -n app-team1 describe rolebindings cicd-token-deployment-clusterrole
Name:         cicd-token-deployment-clusterrole
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  deployment-clusterrole
Subjects:
  Kind            Name        Namespace
  ----            ----        ---------
  ServiceAccount `cicd-token``app-team1`
```



## Task 2. drain - highly-available（4/25%）

Task weight: 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> Set the node named `k8s-worker1` as unavailable and reschedule all the pods running on it

> **任务：**
>
> 将名为 `k8s-worker1` 的 node 设置为不可用， 并重新调度该 node 上所有运行的 pods

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 确认节点状态

```bash
$ kubectl get nodes
NAME          STATUS   ROLES                  AGE   VERSION
k8s-master    Ready    control-plane,master   43d   v1.23.3
k8s-worker1   Ready    <none>                 43d   v1.23.3
k8s-worker2   Ready    <none>                 43d   v1.23.3
```

3. 驱逐应用，并设置节点不可调度

```bash
$ kubectl drain k8s-worker1
node/k8s-worker1 cordoned
error: unable to drain node "k8s-worker1" due to error:[cannot delete DaemonSet-managed Pods (use `--ignore-daemonsets` to ignore): kube-system/calico-node-g5wj7, kube-system/kube-proxy-8pv56, cannot delete Pods with local storage (use `--delete-emptydir-data` to override): kube-system/metrics-server-5fdbb498cc-k4mgt], continuing command...
There are pending nodes to be drained:
 k8s-worker1
cannot delete DaemonSet-managed Pods (use `--ignore-daemonsets` to ignore): kube-system/calico-node-g5wj7, kube-system/kube-proxy-8pv56
cannot delete Pods with local storage (use `--delete-emptydir-data` to override): kube-system/metrics-server-5fdbb498cc-k4mgt

*$ kubectl drain k8s-worker1 --ignore-daemonsets --delete-emptydir-data
```

4. 验证

```bash
$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE   VERSION
k8s-master    Ready                      control-plane,master   84m   v1.23.3
k8s-worker1   Ready,`SchedulingDisabled` <none>                 79m   v1.23.3
k8s-worker2   Ready                      <none>                 76m   v1.23.3
```



## Task 3. upgrade - Kubeadm（7/25%）

Task weight: 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Given an existing Kubernetes cluster running version `1.23.4`, upgrade all of the Kubernetes control plane and node components on the **master node only** to version `1.23.4` 
>
> - [ ] You are also expected to upgrade `kubelet` and `kubectl` on the master node 
>

<div style="background: #ffedcc; padding: 12px; line-height: 24px; margin-bottom: 24px;">
Be sure to drain the master node before upgrading it and uncordon it after the upgrade. do not upgrade the worker nodes,etcd,the container manager,the CNI plugin,the DNS service or any other addons
</div> 


> **任务：**
>
> - [ ] 现有的 kubernetes 集群正在运行的版本是 `1.23.4`。 **仅将主节点上**的所有 kubernetes 控制平面和节点组件升级到版本 `1.23.4`。
>
> - [ ] 另外， 在主节点上升级 `kubelet` 和 `kubectl`
>

<div style="background: #ffedcc; padding: 12px; line-height: 24px; margin-bottom: 24px;">
确保在升级前 drain 主节点， 并在升级后 uncordon 主节点。请不要升级工作节点，etcd，container 管理器，CNI 插件，DNS 服务或任何其他插件
</div> 
答案:

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 确认节点状态

```bash
$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE   VERSION
k8s-master    Ready                      control-plane,master   97m  `v1.23.3`
k8s-worker1   Ready,SchedulingDisabled   <none>                 92m   v1.23.3
k8s-worker2   Ready                      <none>                 89m   v1.23.3
```

3. 登录到 k8s-master

```bash
*$ ssh k8s-master

*$ sudo -i
```

4. Call "kubeadm upgrade" / **For the first control plane node** / ==Upgrade kubeadm:==
   执行 "kubeadm upgrade" / **升级第一个控制面节点** / ==升级 kubeadm：==

```bash
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.23.4-00 && \
apt-mark hold kubeadm

```

5. ==Verify the upgrade plan:==（验证升级计划：）

```bash
kubeadm version

kubeadm upgrade plan

```

6. ==Choose a version to upgrade to, and run the appropriate command. For example:==（选择要升级到的目标版本，运行合适的命令。例如：）

```bash
kubeadm upgrade apply --help | grep etcd

kubeadm upgrade apply v1.23.4 --etcd-upgrade=false -y

```

7. ==Drain the node==（腾空节点）

```bash
kubectl drain k8s-master --ignore-daemonsets

```

8. ==Upgrade the kubelet and kubectl:==（升级 kubectl 和 kubelet）

```bash
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.23.4-00 kubectl=1.23.4-00 && \
apt-mark hold kubelet kubectl

```

9. ==Restart the kubelet:==（重启 kubelet）

```bash
systemctl daemon-reload 
systemctl restart kubelet

```

10. ==Uncordon the node==（解除节点的保护）

```bash
kubectl uncordon k8s-master
```

11. 验证结果

```bash
<Ctrl-D>

$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE    VERSION
k8s-master    Ready                      control-plane,master   157m  `v1.23.4`
k8s-worker1   Ready,SchedulingDisabled   <none>                 152m   v1.23.3
k8s-worker2   Ready                      <none>                 149m   v1.23.3

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.4",....
```



## Task 4. snapshot - Implement etcd（7/25%）

Task weight: 7%

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">No configuration context change required for this item.
</div>

> **Task:**
>
> - [ ] First, create a snapshot of the existing etcd instance running at https://127.0.0.1:2379, SAVING THE SNAPSHOT TO `/srv/backup/etcd-snapshot.db`
>

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">Creating a snapshot of the given instance is expected to complete in seconds. if the operation seems to hang,something's likely wrong with your command.Use CTRL + C to cancel the operation and try again
</div>

> - [ ] Next, restore an existing,previous snapshot located at `/srv/data/etcd-snapshot-previous.db` 

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">The following TLS certificates/key are supplied for connecting to the server with <a>etcdctl</a>:
  <li> CA certificate: <a>/opt/KUIN00601/ca.crt</a>
  <li> Client certificate: <a>/opt/KUIN00601/etcd-client.crt</a>
  <li> Client key: <a>/opt/KUIN00601/etcd-client.key</a>
</div>


<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">此项目无需更改配置环境。
</div>

> **任务：**
>
> - [ ] 首先，为运行在 https://127.0.0.1:2379上的现有`etcd`实例创建快照，并将快照保存到`/srv/backup/etcd-snapshot.db`。
>

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">为给定实例创建快照预计能在几秒钟内完成。 如果该操作似乎挂起， 则命令可能有问题。 用 <kbd>CTRL</kbd>+<kbd>c</kbd> 来取消操作， 然后重试。
</div>

> - [ ] 然后，还原位于`/srv/data/etcd-snapshot-previous.db`的现有先前快照。
>

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">提供了以下TLS证书和密钥，以通过 <a>etcdctl</a> 连接到服务器。
<li> CA 证书：<a>/opt/KUIN00601/ca.crt</a>
<li> 客户端证书：<a>/opt/KUIN00601/etcd-client.crt</a> 
<li> 客户端密钥：<a>/opt/KUIN00601/etcd-client.key</a>
</div>


<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
参考网址: <a href=https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#built-in-snapshot>https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#built-in-snapshot</a>
</div>
**答案:**

1. 备份命令

```bash
$ ETCDCTL_API=3 etcdctl snapshot save --help

*$ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/opt/KUIN00601/ca.crt \
  --cert=/opt/KUIN00601/etcd-client.crt --key=/opt/KUIN00601/etcd-client.key \
  snapshot save /srv/backup/etcd-snapshot.db
  
```

2. 还原命令

```bash
*$ sudo mv /var/lib/etcd /var/lib/etcd.bk

*$ sudo chown $USER /srv/data/etcd-snapshot-previous.db

*$ sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/opt/KUIN00601/ca.crt \
  --cert=/opt/KUIN00601/etcd-client.crt --key=/opt/KUIN00601/etcd-client.key \
  --data-dir /var/lib/etcd \
  snapshot restore /srv/data/etcd-snapshot-previous.db
  
```

5. 验证

```bash
$ ETCDCTL_API=3 etcdctl snapshot status /data/backup/etcd-snapshot.db
89703627, 14521, 1929, 4.3 MB

$ kubectl get componentstatuses
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE                         ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health":"true","reason":""}
```



## Task 5. network policy - network interface（7/20%）

Task weight: 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Create a new `NetworkPolicy` named `allow-port-from-namespace` that allows Pods in the existing namespace `internal` to connect to port `8080` of other pods in the same namespace
>
> - [ ] Ensure that the new `NetworkPolicy`: 
>    - **does not allow** access to pods not listening on port `8080`
>     - **does not allow** access from pods not in namespace `internal`

> **任务：**
>
> - [ ] 创建一个名为`allow-port-from-namespace`的新`NetworkPolicy`， 以允许现有 namespace `internal` 中的 Pods 连接到同一 namespace 中其他 Pods 的端口 `8080`。  
>
> - [ ] 确保新的 `NetworkPolicy`： 
>   - **不允许**对没有在监听端口 `8080` 的 Pods 的访问
>   - **不允许**不来自 namespace `internal` 的 Pods 的访问

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
<li> 务必分析清楚规则是进还是出
<li> 考试时候，对应的namespace可能不存在
</div>

**答案:**

1. 切换 kubernetes

```bash
$ kubectl config use-context ck8s
```

2. 确认 namespace internal 是否存在

```bash
$ kubectl get namespaces internal
NAME       STATUS   AGE
internal   Active   41m
```

3. 查看标签

```bash
*$ kubectl get namespaces internal --show-labels 
NAME     STATUS   AGE    LABELS
internal Active   111s  `kubernetes.io/metadata.name=internal`
```

4. 编辑 yaml

```bash
*$ echo set number et ts=2 cuc > ~/.vimrc

$ vim 5.yml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
# name: test-network-policy
  name: allow-port-from-namespace 
# namespace: default
  namespace: internal
spec:
# podSelector:
  podSelector: {}
#   matchLabels:
#     role: db
  policyTypes:
  - Ingress
# - Egress
  ingress:
  - from:
#   - ipBlock:
#       cidr: 172.17.0.0/16
#       except:
#       - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: internal
#   - podSelector:
#       matchLabels:
#         role: frontend
    ports:
    - protocol: TCP
#     port: 6379
      port: 8080
# egress:
# - to:
#   - ipBlock:
#       cidr: 10.0.0.0/24
#   ports:
#   - protocol: TCP
#     port: 5978
```

5. 应用

```bash
*$ kubectl apply -f 5.yml
```

6. 验证

```bash
$ kubectl -n internal describe networkpolicies allow-port-from-namespace 
Name:         allow-port-from-namespace
Namespace:    internal
Created on:   YYYY-mm-dd 21:39:09 +0800 CST
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     <none> (Allowing the specific traffic to all pods in this namespace)
  Allowing ingress traffic:
    To Port: 8080/TCP
    From:
      NamespaceSelector: kubernetes.io/metadata.name=internal
  Not affecting egress traffic
  Policy Types: Ingress
```



## Task 6. expose - service types（7/20%）

Task weight: 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Reconfigure the existing deployment `front-end` and add a port specification named `http` exposing port `80/tcp` of the existing container `nginx`. 
>
> - [ ] Create a new service named `front-end-svc` exposing the container port `http`. 
>
> - [ ] Configure the new service to also expose the individual pods via a `NodePort` on the nodes on which they are scheduled.

> **任务**
>
> - [ ] 请重新配置现有的 deployment `front-end`：添加名为 `http` 的端口规范来公开现有容器 `nginx` 的端口 `80/tcp`。 
>- [ ] 创建一个名为 `front-end-svc` 的新服务， 以公开容器端口 `http`。 
> - [ ] 配置此服务， 以通过在排定的节点上的 `NodePort` 来公开各个 pods。

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 确认 deployments

```bash
$ kubectl get deployments.apps front-end
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
`front-end` 1/1     1            1           10m
```

3. 获取 ports 编写信息

```bash
$ kubectl explain --help

$ kubectl explain pod.spec.containers

$ kubectl explain pod.spec.containers.ports
```

4. 编辑 deployments front-end

```bash
*$ kubectl edit deployments.apps front-end
```

```yaml
...此处省略...
  template:
...此处省略...
    spec:
      containers:
      - image: nginx
# 添加3行
        ports:
        - name: http
          containerPort: 80
...此处省略...
```

```bash
$ kubectl get deployments.apps front-end
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
front-end  `1/1`    1            1           12m
```

5. 创建 Service

```bash
*$ kubectl expose deployment front-end \
--port=80 --target-port=http \
--name=front-end-svc \
--type=NodePort

```

6. 验证

```bash
$ kubectl get services front-end-svc
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
front-end-svc  `NodePort`  10.106.46.251   <none>        80:`32067`/TCP   39s

$ curl k8s-worker1:32067
...输出省略...
<title>Welcome to nginx!</title>
...输出省略...
```



## Task 7. ingress nginx - Ingress controllers（7/20%）

Task wight: 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Create a new nginx Ingress resource as follows:
>   - Name: `ping`
>   - Namespace: `ing-internal`
>   - Exposing service `hi` on path `/hi` using service port `5678` 

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">The availability of service hello can be checked using the following command,which should return hi: <br></div>

```bash
$ curl -kL <INTERNAL_IP>/hi
```



> **任务：**
>
> - [ ] 如下创建一个新的 nginx ingress 资源：
>  - 名称： `ping`
>   - namespace： `ing-internal` 
>   - 使用服务端口 `5678` 在路径`/hi` 上公开服务 `hi` 
> 

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">可以使用以下命令检查服务 hello 的可用性， 该命令返回 hi：<br></div>

```bash
$ curl -kL <INTERNAL_IP>/hi
```



**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 确认 ingressclasses（`本人考试时，这个类不存在`）

```bash
*$ kubectl get ingressclasses.networking.k8s.io
NAME    CONTROLLER             PARAMETERS   AGE
`nginx` k8s.io/ingress-nginx   <none>       131m

$ kubectl explain ingress.spec
...输出省略...
  `ingressClassName` <string>
```

3. 编辑  yaml 文件

```bash
$ vim 7.yml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
# name: minimal-ingress
  name: ping
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
# 添加1行
  namespace: ing-internal
spec:
# ingressClassName: nginx-example
  ingressClassName: nginx
  rules:
  - http:
      paths:
#     - path: /testpath
      - path: /hi
        pathType: Prefix
        backend:
          service:
#           name: test
            name: hi
            port:
#             number: 80
              number: 5678
```

3. 应用生效

```bash
*$ kubectl apply -f 7.yml
```

4. 验证

```bash
$ kubectl get pods -A -o wide | grep ingress
ingress-nginx   ingress-nginx-admission-patch-hgxhp         0/1     Completed           0             45m     <none>            k8s-worker2   <none>           <none>
ingress-nginx  `ingress-nginx-controller-56b4f58c58-lmbfw`   1/1     Running             0             30m   `192.168.147.130`   k8s-worker2   <none>           <none>

$ curl -kL http://192.168.147.130/hi
hi
```



## Task 8. scale - scale applications（4/15%）

Task weight: 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] scale the deployment `webserver` to `6` pods

> **任务：**
>
> - [ ] 将 deployment `webserver` 扩展至 `6 `pods 

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 查看

```bash
$ kubectl get deployments.apps webserver 
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
webserver  `1/1`    6            6           30s
```

3. 扩展副本

```bash
*$ kubectl scale deployment webserver --replicas=6
```

4. 验证

```bash
$ kubectl get deployments.apps webserver -w
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
webserver  `6/6`    6            6           120s
<Ctrl-C>
```



## Task 9. schedule - Pod scheduling（4/15%）

Task weight 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Schedule a pod as follows:
>  	- Name: `nginx-kusc00401`
>   	- image: `nginx`
>   	- Node selector: `disk=spinning`

> **任务**
>
> - [ ] 按如下要求调度一个 pod：
>  - 名称： `nginx-kusc00401` 
>   - image: `nginx` 
>   - Node selector: `disk=spinning ` 

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 创建 pod

```bash
*$ vim 9.yml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
# name: nginx
  name: nginx-kusc00401
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
#   disktype: ssd
    disk: spinning
```

3. 应用

```bash
*$ kubectl apply -f 9.yml
```

4. 确认

```bash
$ kubectl get pod nginx-kusc00401 -o wide -w
NAME              READY   STATUS    RESTARTS   AGE   IP              NODE          NOMINATED NODE   READINESS GATES
nginx-kusc00401   1/1    Running   0          11s   172.16.126.21   `k8s-worker2`  <none>           <none>
<Ctrl-C>

$ kubectl get nodes --show-labels | grep disk=spinning
k8s-worker2   Ready                      <none>                 43d   v1.23.3   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,`disk=spinning`,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s-worker2,kubernetes.io/os=linux
```



## Task 10. describe - Pod scheduling（4/15%）

Task weight 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Check to see how many nodes are ready(not including nodes tainted `NoSchedule`) and write the number to `/opt/KUSC00402/kusc00402.txt`

> **任务：**
>
> - [ ] 检查有多少个 nodes 已准备就绪（不包括被打上 tainted: `NoSchedule` 的节点） ， 并将数量写入`/opt/KUSC00402/kusc00402.txt ` 

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
<li> 仔细看 taints 是否为 NoSchedule
</div>

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 确认节点状态

```bash
$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE   VERSION
k8s-master    Ready                      control-plane,master   43d   v1.23.4
k8s-worker1   Ready,SchedulingDisabled   <none>                 43d   v1.23.3
k8s-worker2   Ready                      <none>                 43d   v1.23.3
```

3. 检查有 Taint 的节点

```bash
*$ kubectl describe nodes | grep -i -e Hostname -e taints
                    kubernetes.io/hostname=k8s-master
Taints:             node-role.kubernetes.io/master:NoSchedule
  Hostname:    k8s-master
                    kubernetes.io/hostname=k8s-worker1
Taints:             node.kubernetes.io/unschedulable:NoSchedule
  Hostname:    k8s-worker1
                    kubernetes.io/hostname=k8s-worker2
Taints:             <none>
  Hostname:    k8s-worker2
```

4. 写入结果

```bash
*$ echo 1 > /opt/KUSC00402/kusc00402.txt
```



## Task 11. multi Containers（4/15%）

Task weight 4%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Create a pod named `kucc1` with a single app container for each of the following images running in side (there may be between 1 and 4 images specified): 
>
> ​	`nginx` + `redis` + `memcached` + `consul`

> **任务：**
>
> - [ ] 创建一个名字为`kucc1`的 pod， 在pod里面分别为以下每个images单独运行一个app container（可能会有 1-4 个 images），容器名称和镜像如下：
>
> ​	`nginx` + `redis` + `memcached` + `consul`

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 创建 pod

```bash
*$ vim 11.yml 
```

```yaml
apiVersion: v1
kind: Pod
metadata:
# name: myapp-pod
  name: kucc1
  labels:
    app: myapp
spec:
  containers:
# - name: myapp-container
  - name: nginx
#   image: busybox:1.28
    image: nginx
# 添加
  - name: redis
    image: redis
  - name: memcached
    image: memcached
  - name: consul
    image: consul
```

3. 应用

```bash
*$ kubectl apply -f 11.yml
```

4. 验证

```bash
$ kubectl get pod kucc1 -w
NAME    READY   STATUS    RESTARTS   AGE
kucc1  `4/4`    Running   0          59s
<Ctrl-C>
```



## Task 12. pv - persistent volumes（4/10%）

Task weight: 4%
 Set configuration context:

> **Task:**
>
> - [ ] Create a persistent volume with name `app-data`, of capacity `1Gi` and access mode `ReadWriteMany`. The type of volume is `hostPath` and its location is `/srv/app-data`

> **任务：**
>
> - [ ] 创建名为 `app-data` 的 persistent volume， 容量为 `1Gi`， 访问模式为 `ReadWriteMany`。 volume类型为 `hostPath`， 位于`/srv/app-data`   

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 编辑 yaml

```bash
*$ vim 12.yml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
# name: task-pv-volume
  name: app-data
  labels:
    type: local
spec:
# storageClassName: manual
  capacity:
#   storage: 10Gi
    storage: 1Gi
  accessModes:
#   - ReadWriteOnce
    - ReadWriteMany
  hostPath:
#   path: "/mnt/data"
    path: "/srv/app-data"
# 增加
    type: DirectoryOrCreate
```

3. 应用生效

```bash
*$ kubectl apply -f 12.yml
```

4. 验证

```bash
$ kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
`app-data` `1Gi`      `RWX`           Retain           Available                                   4s
```



## Task 13. pvc - persistent volume claims（7/10%）

Task weight: 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Create a new `PersistenVolumeClaim`: 
>   - Name: `pv-volume` 
>   - Class: `csi-hostpath-sc` 
>   - Capacity: `10Mi`
>
> - [ ] Create a new pod which mounts the `PersistenVolumeClaim` as a volume:  
>   - Name: `web-server`
>   - image: `nginx`
>   - Mount path: `/usr/share/nginx/html`
>
> - [ ] Configure the new pod to have `ReadWriteOnce` access on the volume.
>
> - [ ] Finally, using `kubectl edit` or `kubectl patch` expand the `PersistentVolumeClaim` to a capacity of `70Mi` and record that change. 

> **任务：**
>
> - [ ] 创建一个新的 `PersistentVolumeClaim`： 
>   - 名称： `pv-volume` 
>   - class： `csi-hostpath-sc` 
>   - 容量： `10Mi ` 
>
> - [ ] 创建一个新的 pod， 此 pod 将作为 volume 挂载到 `PersistentVolumeClaim`： 
>   - 名称：`web-server` 
>   - image：`nginx` 
>   - 挂载路径：`/usr/share/nginx/html` 
>
> - [ ] 配置新的 pod， 以对 volume 具有 `ReadWriteOnce` 权限。 
>
> - [ ] 最后， 使用 `kubectl edit` 或者 `kubectl patch` 将 `PersistentVolumeClaim` 的容量扩展为 `70Mi`， 并记录此次更改。 

**答案:**

1. 切换 kubernetes

```bash
$ kubectl config use-context ck8s
```

2. 创建 pvc

```bash
*$ vim 13pvc.yml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
# name: claim1
  name: pv-volume
spec:
  accessModes:
    - ReadWriteOnce
# storageClassName: fast
  storageClassName: csi-hostpath-sc
  resources:
    requests:
#     storage: 30Gi
      storage: 10Mi
```

```bash
*$ kubectl apply -f 13pvc.yml

$ kubectl get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
pv-volume `Bound`   pvc-b0972a71-148c-43fe-8d97-f612a375b2d2   10Mi       RWO            csi-hostpath-sc   4s

$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM               STORAGECLASS      REASON   AGE
app-data                                   1Gi        RWX            Retain           Available                                                  72m
pvc-e66ff049-b07e-4610-bd23-a78ef1b8c747   10Mi       RWO            Delete           Bound       default/pv-volume   csi-hostpath-sc            4m5s
```

3. 创建 pod

```bash
*$ vim 13pod.yml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
# name: task-pv-pod
  name: web-server
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
#       claimName: task-pv-claim
        claimName: pv-volume
  containers:
#   - name: task-pv-container
    - name: web-server
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```

```bash
*$ kubectl apply -f 13pod.yml
pod/web-server created

$ kubectl get pod web-server
NAME         READY   STATUS    RESTARTS   AGE
web-server   1/1     Running   0          9s
```

4. 允许扩容

```bash
*$ kubectl edit storageclasses csi-hostpath-sc
...输出省略...
# 添加1行
allowVolumeExpansion: true

$ kubectl get storageclasses -A 
NAME             PROVISIONER     RECLAIMPOLICY  VOLUMEBINDINGMODE  ALLOWVOLUMEEXPANSION  AGE
csi-hostpath-sc  fuseim.pri/ifs  Delete         Immediate         `true`                 32m
```

5. 并记录此次更改

```bash
*$ kubectl edit pvc pv-volume --record
```

```yaml
...此处省略...
spec:
...此处省略...
#     storage: 10Mi
      storage: 70Mi
...此处省略...
```

6. 确认

```bash
$ kubectl get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
pv-volume  Bound    pvc-9a5fb9b6-b127-4868-b936-cb4f17ef910e  `70Mi`      RWO            csi-hostpath-sc   31m
```



## Task 14. logs - node logging（5/30%）

Task weight: 5%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] Monitor the logs of pod `bar` and: 
>  - Exract log lines corresponding to error `unable-to-access-website` 
>   - Write them to `/opt/KUTR00101/bar`

> **任务：**
>
> - [ ] 监控 pod `bar` 的日志：
>  - 提取与错误 `unable-to-access-website` 相对应的日志行 
>   - 将这些日志行写入到`/opt/KUTR00101/bar`

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 查看 logs

```bash
*$ kubectl logs bar | grep unable-to-access-website > /opt/KUTR00101/bar
```

3. 验证

```bash
$ cat /opt/KUTR00101/bar
YYYY-mm-dd 07:13:03,618: ERROR `unable-to-access-website`
```



## Task 15. sidecar - Manage container stdout（7/30%）

Task weight 7%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **context:**
>
> Without changing its existing containers, an existing pod needs to be integrated into kubernetes's built-in logging architecture (e.g. kubectl logs). Adding a streaming sidecar container is a good and common way to accomplish this requirement.
>
> **Task:**
>
> - [ ] Add a `busybox` sidecar container name is **sidedcar** to the existing pod `big-corp-app`. The new sidecar container has to run the following command:
>
>   ```bash
>   /bin/sh -c tail -f /var/log/legacy-app.log
>   ```
>
> - [ ] Use a volume mount named `logs` to make the file `/var/log/legacy-app.log` available to the sidecar container.
>

<div style="background: #ffedcc; padding: 12px; line-height: 24px; margin-bottom: 24px;">
  Don't modify the existing container.<br>
  Don't modify the path of the log file,both containers must access it at <a>/var/log/big-corp-app.log</a>.</div> 



> **内容：**
>
> 在不更改其现有容器的情况下， 需要将一个现有的 pod 集成到 kubernetes 的内置日志记录体系结构中（例如 kubectl logs） 。 添加 streamimg sidecar 容器是实现此要求的一种好方法。
>
> **任务：**
>
> - [ ] 将一个 `busybox` sidecar 容器名称为**sidecar**添加到现有的 `big-corp-app`。 新的 sidecar 容器必须运行以下命令：
>
>   ```bash
>   /bin/sh -c tail -f /var/log/legacy-app.log
>   ```
>
> - [ ] 使用名为 `logs` 的 volume mount 来让文件`/var/log/legacy-app.log` 可用于 sidecar 容器
>

<div style="background: #ffedcc; padding: 12px; line-height: 24px; margin-bottom: 24px;">
不要更改现有容器<br>
不要修改日志文件的路径， 两个容器必须通过<a>/var/log/big-corp-app.log</a>来访问该文件。</div> 


**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s 
```

2. 编辑 yaml

```bash
*$ kubectl get pod big-corp-app -o yaml > 15.yml

*$ vim 15.yml
```

```yaml
...此处省略...
spec:
  containers:
...此处省略...
    volumeMounts:
# 已有容器 增加2行
    - name: logs
      mountPath: /var/log
# 新容器 增加5行
  - name: sidecar
    image: busybox
    args: [/bin/sh, -c, 'tail -f /var/log/legacy-app.log']
    volumeMounts:
    - name: logs
      mountPath: /var/log
...此处省略...
  volumes:
# 增加 2 行
  - name: logs
    emptyDir: {}
...此处省略...
```

```bash
mA
*$ kubectl replace -f 15.yml --force
pod "big-corp-app" deleted
pod/big-corp-app replaced

mB
*$ kubectl delete -f 15.yml
*$ kubectl apply -f 15.yml
```

3. 确认

```bash
$ kubectl get pod big-corp-app -w
NAME           READY   STATUS    RESTARTS   AGE
big-corp-app  `2/2`    Running   1          37s
<Ctrl-D>
```



## Task 16. top - monitor applications（5/30%）

Task weight: 5%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] From the pod label `name=cpu-loader`, find pods running high cpu workloads and write the name of the pod consuming most cpu to the file `/opt/KUTR00401/KUTR00401.txt` (which already exists)

> **任务：**
>
> - [ ] 通过 pod label `name=cpu-loader`， 找到运行时占用大量 CPU 的 pod， 并将占用 CPU 最高的 pod 名称写入到文件`/opt/KUTR00401/KUTR00401.txt`（已存在）

**答案:**

1. 切换 kubernetes 集群

```bash
$ kubectl config use-context ck8s
```

2. 查找

```bash
$ kubectl top pod -h

*$ kubectl top pod -l name=cpu-loader -A
NAMESPACE   NAME                          CPU(cores)   MEMORY(bytes)
default    `bar`                          1m          `5Mi`
default     cpu-loader-5b898f96cd-56jf5   0m           3Mi
default     cpu-loader-5b898f96cd-9zlt5   0m           4Mi
default     cpu-loader-5b898f96cd-bsvsb   0m           4Mi           
```

3. 写入

```bash
*$ echo bar > /opt/KUTR00401/KUTR00401.txt
```



## Task 17. Daemon - cluster component（13/30%）

Task weight: 13%
 Set configuration context:

```bash
$ kubectl config use-context ck8s
```

> **Task:**
>
> - [ ] A kubernetes woker node, named `k8s-worker1` is in state `NotReady`. Investigate why this is the case, and perform any appropriate steps to bring the node to a `Ready` state, ensuring that any changes are made permanent.

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">
  You can ssh to the failed node useing:<br>
  $ <a>ssh wk8s-node-0</a><br>
	You can assume elevated privileges on the node with the following command:<br>
  $ <a>sudo -i</a>
</div>



> **任务：**
>
> - [ ] 名为 `k8s-worker1` 的 kubernetes worker node 处于 `NotReady` 状态。 调查发生这种情况的原因， 并采取相应措施将 node 恢复为 `Ready` 状态，确保所做的任何更改永久生效。

<div style="background: #CFE2F0; padding: 12px; line-height: 24px; margin-bottom: 24px; ">
  可使用以下命令通过 ssh 连接到故障 node：<br>
  $ <a>ssh wk8s-node-0</a><br>
	可使用以下命令在该 node 上获取更高权限：<br>
  $ <a>sudo -i</a>
</div>


<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
<li> 这题与第二题有关联
  <li> kiosk@k8s-master:~$ <b>media/cka-setup 17</b>
</div>



**答案:**

1. 切换集群环境

```bash
$ kubectl config use-context ck8s
```

2. 确认节点状态

```bash
$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE     VERSION
k8s-master    Ready                      control-plane,master   43d   v1.23.4
k8s-worker1  `NotReady`                  <none>                 43d   v1.23.3
k8s-worker2   Ready                      <none>                 43d   v1.23.3

$ kubectl describe nodes k8s-worker1
...输出省略...
Conditions:
  Type                 Status    LastHeartbeatTime                 LastTransitionTime                Reason              Message
  ----                 ------    -----------------                 ------------------                ------              -------
  NetworkUnavailable   False     Tue, 31 May YYYY 11:25:06 +0000   Tue, 31 May YYYY 11:25:06 +0000   CalicoIsUp          Calico is running on this node
  MemoryPressure       Unknown   Tue, 31 May YYYY 13:51:08 +0000   Tue, 31 May YYYY 13:53:42 +0000  `NodeStatusUnknown   Kubelet stopped posting node status.`
  DiskPressure         Unknown   Tue, 31 May YYYY 13:51:08 +0000   Tue, 31 May YYYY 13:53:42 +0000  `NodeStatusUnknown   Kubelet stopped posting node status.`
  PIDPressure          Unknown   Tue, 31 May YYYY 13:51:08 +0000   Tue, 31 May YYYY 13:53:42 +0000  `NodeStatusUnknown   Kubelet stopped posting node status.`
  Ready                Unknown   Tue, 31 May YYYY 13:51:08 +0000   Tue, 31 May YYYY 13:53:42 +0000  `NodeStatusUnknown   Kubelet stopped posting node status.`
...输出省略...
```

3. 启动服务

```bash
$ ssh k8s-worker1

$ sudo -i

# systemctl enable --now kubelet.service
# systemctl status kubelet
<q>

<Ctrl-D>
<Ctrl-D>
```

4. 确认

```bash
$ kubectl get nodes
NAME          STATUS                     ROLES                  AGE   VERSION
k8s-master    Ready                      control-plane,master   43d   v1.23.4
k8s-worker1  `Ready`,SchedulingDisabled  <none>                 43d   v1.23.3
k8s-worker2   Ready                      <none>                 43d   v1.23.3
```





# A1. 准备练习环境

**[VMware/k8s-master]**

![截屏2022-06-01 00.49.57](https://gitee.com/suzhen99/k8s/raw/master/images/%E6%88%AA%E5%B1%8F2022-06-01%2000.49.57.png)

```bash
sudo mount /dev/sr0 /media/
sudo cp -r /media .
sudo chown -R kiosk media/
media/cka-setup

```

# A2. exam-grade

```bash
$ media/cka-grade

 Spend Time: up 1 hours, 1 minutes  Wed 01 Jun YYYY 04:58:06 PM UTC
================================================================================
 PASS	Task1.  - RBAC
 PASS	Task2.  - drain
 PASS	Task3.  - upgrade
 PASS	Task4.  - snapshot
 PASS	Task5.  - network-policy
 PASS	Task6.  - service
 PASS	Task7.  - ingress-nginx
 PASS	Task8.  - replicas
 PASS	Task9.  - schedule
 PASS	Task10. - NoSchedule
 PASS	Task11. - multi_pods
 PASS	Task12. - pv
 PASS	Task13. - Dynamic-Volume
 PASS	Task14. - logs
 PASS	Task15. - Sidecar
 PASS	Task16. - Metric
 PASS	Task17. - Daemon (kubelet, containerd, docker)
================================================================================
 The results of your CKA v1.23:  `PASS`	 Your score: `100`
```

```bash
$ media/cka-grade 1

 Spend Time: up 1 hours, 2 minutes  Wed 01 Jun YYYY 04:58:14 PM UTC
================================================================================
 `PASS`	Task1.  - RBAC
================================================================================
 The results of your CKA v1.23:  FAIL	 Your score: 4
```

