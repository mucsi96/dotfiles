#!/usr/bin/env node
'use strict'

const os = require('os')
const shell = require('shelljs')
const pwd = __dirname
let vscodeDest

switch (os.platform()) {
    case 'darwin':
    vscodeDest = '~/Library/Application\ Support/Code/User'
    break
  default:
    shell.echo(`OS ${os.platform()} is currently not supported`)
    shell.exit(1)
}

if (vscodeDest && !shell.test('-e', vscodeDest)) {
  shell.echo('Installing Visual Studio Code config')
  shell.ln('-s', `${pwd}/User`, vscodeDest)
}

