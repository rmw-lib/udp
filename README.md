<!-- 本文件由 ./readme.make.md 自动生成，请不要直接修改此文件 -->

# @rmw/udp


### 打洞流程

先给服务器发送 ping 
  
  * 本地port（用来测试是否是内网）
  * hash(本地port + 远程端口)

服务器响应 pong 内容 ip port

服务器用 nat socket ping ip+本地port

客户端收到服务器请求，认为自己在外网

客户端没有收到服务器请求，认为自己在内网

交换密钥

AES-GCM 加密

##  安装

```
yarn add @rmw/udp
```

或者

```
npm install @rmw/udp
```

## 使用

```coffee
#!/usr/bin/env coffee
import xxx from '@rmw/xxx'
# import {xxx as Xxx} from '@rmw/xxx'
import test from 'tape-catch'

test 'xxx', (t)=>
  t.equal xxx(1,2),3
  # t.deepEqual Xxx([1],[2]),[3]
  t.end()

```

## 关于

本项目隶属于**人民网络([rmw.link](//rmw.link))** 代码计划。

![人民网络](https://raw.githubusercontent.com/rmw-link/logo/master/rmw.red.bg.svg)
