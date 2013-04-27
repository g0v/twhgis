#!/usr/bin/env lsc -cj
author:
  name: ['Chia-liang Kao']
  email: 'clkao@clkao.org'
name: 'twhgis'
description: 'historical geographic information data for Taiwan'
version: '0.0.1'
repository:
  type: 'git'
  url: 'git://github.com/g0v/twhgis.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
  """
engines: {node: '*'}
dependencies: {}
devDependencies:
  LiveScript: \1.1.x
  optimist: \*
  csv: \*
  mkdirp: \*
  moment: \*
optionalDependencies: {}
