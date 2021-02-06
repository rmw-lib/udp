#!/usr/bin/env coffee

import portControl from 'nat-puncher'

export init = =>
  fail = []
  for [protocol,ok] in Object.entries(
    await portControl.probeProtocolSupport()
  )
    if ok
      break
    else
      fail.push protocol
  if not ok
    console.log "路由器不支持", fail.join(" / ") , "，无法绑定公网端口"

export default (port) =>
  r = await portControl.addMapping port, port, 0
  if r.protocol
    console.log "#{r.protocol} 路由器端口 #{port} 绑定成功"
  return

