#!/usr/bin/env node
'use strict'

const os = require('os')
const shell = require('shelljs')
const pwd = __dirname
let vscodeDest
let keybindingsSrc

switch (os.platform()) {
  case 'linux':
    vscodeDest = '~/.config/Code/User'
    keybindingsSrc = `${pwd}/User/keybindings.linux.json`
    break
  case 'darwin':
    vscodeDest = '~/Library/Application\ Support/Code/User'
    keybindingsSrc = `${pwd}/User/keybindings.osx.json`
    break
  case 'win32':
    vscodeDest = '${process.env.USERPROFILE}/AppData/Roaming/Code/User'
    keybindingsSrc = `${pwd}/User/keybindings.win.json`
    break
  default:
    shell.echo(`OS ${os.platform()} is currently not supported`)
    shell.exit(1)
}

if (vscodeDest && !shell.test('-e', vscodeDest)) {
  shell.echo('Installing Visual Studio Code config')
  shell.ln('-s', `${pwd}/User`, vscodeDest)
  shell.ln('-s', keybindingsSrc, `${vscodeDest}/keybindings.json`)
}

