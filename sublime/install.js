#!/usr/bin/env node
'use strict'

const os = require('os')
const shell = require('shelljs')
const pwd = __dirname
let sublimeDest
let sublimeBinDest

switch (os.platform()) {
  case 'linux':
    sublimeDest = '~/.config/sublime-text-3/Packages/User'
    sublimeBinDest = '/usr/bin/subl'
    break
  case 'darwin':
    sublimeDest = '~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User'
    sublimeBinDest = '/usr/local/bin/subl'
    break
  case 'win32':
    sublimeDest = `${process.env.USERPROFILE}//AppData//Roaming//Sublime Text 3//Packages//User`
    break
  default:
    shell.echo(`OS ${os.platform()} is currently not supported`)
    shell.exit(1)
}

if (sublimeDest && !shell.test('-e', sublimeDest)) {
  shell.echo('Installing Sublime config')
  shell.ln('-s', `${pwd}/User`, sublimeDest)
}

if (sublimeBinDest && !shell.test('-e', sublimeBinDest)) {
  shell.echo('Installing Sublime binary')
  shell.ln('-s', '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl', sublimeBinDest)
}
