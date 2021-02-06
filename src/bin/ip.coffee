#!/usr/bin/env coffee

import {dumpUInt16} from './int'
import {binary} from '../const.mjs'

export dumpIpv4 = (ip, port) =>
  Buffer.concat [
    Buffer.from(parseInt(i) for i in ip.split("."))
    dumpUInt16(port)
  ]

export loadIpv4 = (bin) =>
  ip = []
  n = 0
  while n<4
    ip.push bin[n++].toString()

  return [ip.join("."),bin.readUInt16BE(4,6)]

# do =>
#   r = dumpIpv4("127.0.0.1",23323)
#   console.log r.length, r
#   console.log loadIpv4(r)
