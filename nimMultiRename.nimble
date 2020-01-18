# Package

version       = "0.1.1"
author        = "David Krause"
description   = "A multi rename tool for the command line"
license       = "MIT"
srcDir        = "src"
bin           = @["mmv"]



# Dependencies

requires "nim >= 1.0.4"
requires "cligen"
requires "glob"
