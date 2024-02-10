# lorem ipsum door shit (real)
import std/[asyncdispatch, options, strutils], dimscord, lorem, ../coloring

proc loremIpsum*(bot: DiscordClient, m: Message, mode: string) {.async.} =
  var
    data: string
    embed = Embed(title: some "**Lorem Ipsum Generator**", color: randColor())

  case mode.toLowerAscii()
  of "word", "single":
    data = word()
  of "sentence", "line":
    data = sentence()
  of "para", "paragraph":
    data = paragraph()

  if data.len > 0:
    embed.description = some "```" & data & "```"
  else:
    embed.description = some ":x: Invalid mode: " & mode & ":x:"
    embed.fields =
      some @[
        EmbedField(name: "`word`, `single`", value: "Generate a single word."),
        EmbedField(
          name: "`sentence`, `line`",
          value: "Generate an entire sentence of Lorem Ipsum.",
        ),
        EmbedField(
          name: "`para`, `paragraph`",
          value:
            "Generate an entire essay of Lorem Ipsum. It can't get any better than this.",
        )
      ]

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
