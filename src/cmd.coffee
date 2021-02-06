#!/usr/bin/env coffee

export CMD = {
  PING : 1
  PONG : 2
}

export CMD_BIN = do =>
  r = {}
  for [k,v] in Object.entries CMD
    r[k] = Buffer.from([v])
  r
