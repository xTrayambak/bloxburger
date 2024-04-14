import std/[asyncdispatch, cpuinfo, options, strutils], dimscord, ../coloring

proc debugCmd*(bot: DiscordClient, m: Message) {.async.} =
  var
    embed =
      Embed(
        title: some "**Debug Information**",
        description:
          some "Tray generally runs this thing on his self-hosted server, so yeah.",
        color: randColor()
      )

  var fields: seq[EmbedField] = @[]

  let aStats = getAllocStats()

  for f in [
    EmbedField(
      name: "**Allocated Memory**",
      value: $(getOccupiedMem() / (1024 * 1024 * 1024)) & " GB",
    ),
    EmbedField(
      name: "**Allocated Shared Memory**",
      value: $(getOccupiedSharedMem() / (1024 * 1024 * 1024)) & " GB",
    ),
    EmbedField(
      name: "**Reference Counter Statistics**",
      value: "```" & GC_getStatistics() & "```",
    ),
    EmbedField(name: "**Compiled using Nim version**", value: NimVersion),
    EmbedField(name: "**Compiled On**", value: CompileDate & ' ' & CompileTime),
    EmbedField(name: "**CPU Endianness**", value: $cpuEndian),
    EmbedField(name: "**Host CPU**", value: hostCPU),
    EmbedField(name: "**Host OS**", value: hostOS),
    EmbedField(
      name: "**CPU Name**",
      value: readFile("/proc/cpuinfo").splitLines()[4].split(": ")[1],
    )
  ]:
    fields.add f

  embed.fields = some fields

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
