import std/[tables, json], jsony, chronicles, librng

var rng = newRNG(algo=MersenneTwister)

proc getMotds*: string =
  let 
    data = "motds.json".readFile().fromJson(seq[Table[string, string]])
    motd = rng.choice(data)

  result = motd["motd"]

  if motd["by"].len > 0:
    result &= " -" & motd["by"]

  info "Chosen MOTD!", motd = result
