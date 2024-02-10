# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = "we yes yes"
license       = "ABSOLUTELY PROPRIETARY"
srcDir        = "src"
bin           = @["bloxburger"]


# Dependencies

requires "nim >= 2.0.0"
requires "https://github.com/xTrayambak/dimscord#master"
requires "jsony >= 1.1.3"
requires "dimscmd >= 1.4.1"
requires "chronicles >= 0.10.3"
requires "nbcnews >= 1.0.6"
requires "algebra >= 0.1.1"
requires "lorem >= 0.1.0"
requires "nph >= 0.3.0"
requires "librng >= 0.1.2"

task fmt, "Format":
  exec "nph src/"
