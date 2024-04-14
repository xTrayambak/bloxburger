import std/[asyncdispatch, options, strutils], dimscord, ../[coloring, assets]

proc purge*(bot: DiscordClient, m: Message, num: int) {.async.} =
  var
    data: string
    embed = Embed(title: some "**" & $num & " messages purged successfully.**", color: randColor())

  embed.footer = some EmbedFooter(
    text: "Literally 1984.",
    iconUrl: some CAT_NOD_GIF
  )

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
