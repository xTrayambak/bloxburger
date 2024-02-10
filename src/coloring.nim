import std/[options, colors], librng

var rng = newRNG(algo=Xoroshiro128StarStar)

proc green*: int {.inline.} =
  colGreen.int

proc yellow*: int {.inline.} =
  colYellow.int

proc blue*: int {.inline.} =
  colBlue.int

proc red*: int {.inline.} =
  colRed.int

proc turquoise*: int {.inline.} =
  colTurquoise.int

proc magenta*: int {.inline.} =
  colMagenta.int

proc purple*: int {.inline.} =
  colPurple.int

proc orange*: int {.inline.} =
  colOrange.int

proc white*: int {.inline.} =
  colWhite.int

const COLORS* = [
  green, yellow, blue, red, turquoise, magenta, purple, orange, white
]

proc randColor*: Option[int] {.inline.} =
  rng.choice(COLORS)().some()
