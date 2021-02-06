#!/usr/bin/env coffee
import upnp from './upnp'
import BASE64 from 'urlsafe-base64'
import {binary} from './const.mjs'
import bls from "@chainsafe/bls"
import {dumpIpv4,loadIpv4} from './bin/ip'
import {dumpUInt16,dumpUInt48} from './bin/int'
import {CMD_BIN,CMD} from './cmd'
import '@rmw/console/global'
import dgram from 'dgram'
import CONFIG from '@rmw/config'
import split_n from 'split_n'
import txtli from './txtli'
import crypto from 'crypto'
import {hash} from 'blake3'

onMessage = (msg, remote)->
  cmd = msg[0]
  msg = msg[1..]
  switch cmd
    when CMD.PING
      {address,port} = remote
      nport = msg.readUInt16BE()
      console.log address+":"+port, "请求连接，外网测试端口", nport
      msg = Buffer.concat [CMD_BIN.PONG, dumpIpv4(address,port)]
      @send msg, port, address
      @send CMD_BIN.PONG, nport, address
    when CMD.PONG
      console.log "服务器 #{remote.address+":"+remote.port} 连接成功", "公网地址 "+loadIpv4(msg).join ":"


nat_test_socket = (port)=>
  socket = dgram.createSocket('udp4')
  new Promise (resolve)=>
    socket.on 'error', (err)=>
      console.log "❌ nat_test_socket", err
      return
    socket.on 'message', (msg, remote)=>
      cmd = msg[0]
      msg = msg[1..]
      switch cmd
        when CMD.PONG
          console.log "这是公网IP", remote
      return
    socket.on 'listening',=>
      resolve(socket)
    socket.bind(port)


do =>
  npsocket = await nat_test_socket(nat)
  {nat, port, seed} = CONFIG

  if seed
    seed = BASE64.decode seed
  else
    seed = crypto.randomBytes(32)
    CONFIG.seed = BASE64.encode seed

  await bls.init('blst-native')
  {SecretKey} = bls
  sk = SecretKey.fromKeygen(seed)
  pk = sk.toPublicKey().toBytes()

  socket = dgram.createSocket('udp4')

  socket.on 'error', (err) =>
    {code} = err
    if code == "EADDRINUSE"
      socket.bind()
      return
    console.log "❌", socket.address(), err.code, err.message
    return

  socket.on 'message', onMessage.bind(socket)

  socket.on 'listening',=>
    host = socket.address()
    if not port
      CONFIG.port = host.port
    {address, port} = host

    console.log "绑定端口", "#{address}:#{port}"

    npport = npsocket.address().port
    console.log "用来测试是否是内网的端口", npport
    npportbin = dumpUInt16 npport

    ping = =>
      now = dumpUInt48 parseInt(new Date()/1000)
      for i in txtli("./ip.txt")
        [ip,port] = split_n(i, ":", 2)
        port = parseInt(port)

        sign = sk.sign(now).toBytes()

        msg = Buffer.concat [CMD_BIN.PING, npportbin, now, sign, pk]

        console.log msg.length,"TODO"

        socket.send msg, port, ip

        console.log "连接服务器", ip+":"+port
    await ping()
    await upnp(npport)
    await ping()

  socket.on 'close', =>
    console.log "socket close"
    process.exit()

  socket.bind(port)

