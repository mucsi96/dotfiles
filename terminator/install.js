#!/usr/bin/env node
'use strict'

var path = require('path')
var os = require('os')
var shell = require('shelljs')
var pwd = __dirname
var terminatorDest

switch (os.platform()) {
  case 'linux':
    terminatorDest = '~/.config/terminator/config'
    break
  default:
    shell.echo('OS ' + os.platform() + ' is currently not supported')
    shell.exit(1)
}

if (terminatorDest && !shell.test('-e', terminatorDest)) {
  shell.echo('Installing Terminator config')
  shell.ln('-s', path.join(pwd, 'config'), terminatorDest)
}
