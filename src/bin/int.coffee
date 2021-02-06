#!/usr/bin/env coffee

import {binary} from '../const.mjs'

export dump =(len, func)=>
  (n)=>
    b = Buffer.allocUnsafe(len)
    func.call b, n
    b

export dumpUInt16 = dump(2, (n)-> @writeUInt16BE(n))
export dumpUInt = dump(4, Buffer.writeUInt32BE)
export dumpUInt48 = dump(6, (n)-> @writeUIntBE n,0,6)

