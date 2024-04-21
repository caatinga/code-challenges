# Package

version       = "0.1.0"
author        = "Caatinga"
description   = "A Nim version of a vault"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["vault"]


# Dependencies

requires "nim >= 2.0.2"
requires "nimword"
requires "nimcrypto"
requires "toml_serialization >= 0.2.12"
