import
  std/[asyncdispatch, asyncfutures, tables, options],
  dimscord,
  nbcnews,
  chronicles,
  ../[assets, coloring]

const POSTS_LIMIT: int = 4

proc getPoliticalNews*(bot: DiscordClient, m: Message) {.async.} =
  info "Fetching political news."

  let data = waitFor getNbcPage()
  let political = data.byCategory["World"]

  info "Aggregating political news."

  var fields: seq[EmbedField] = @[]
  var
    embed =
      Embed(
        title: some ":clown: The Latest Political News :clown:",
        description: some "Please. Just read these, don't argue here.",
        footer:
          some EmbedFooter(
            text:
              "Generated using the **blazingly fast** nbcnews scraper written in Nim!",
            iconUrl: some CAT_NOD_GIF,
          ),
        color: randColor(),
      )

  for politicalPost in political:
    if politicalPost.kind == pkVideo:
      continue

    var name: string

    if politicalPost.breakingNews:
      name &= ":exploding_head: **BREAKING NEWS**: "

    name &= politicalPost.headline

    if politicalPost.breakingNews:
      name &= " :exploding_head:"

    fields.add(
      EmbedField(name: name, value: politicalPost.subhead & '\n' & politicalPost.url)
    )

  embed.fields = some fields

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])

proc getHighlights*(bot: DiscordClient, m: Message) {.async.} =
  info "Fetching highlighted news."

  let data = waitFor getNbcPage()
  let highlighted = data.highlighted

  var fields: seq[EmbedField] = @[]

  var
    embed =
      Embed(
        title: some ":star: News Highlights :star:",
        description:
          some "If they're shit, please don't nag me about it.\nI can't do anything if NBC journalists like to highlight shit.",
        color: randColor()
      )

  for post in highlighted:
    fields.add(EmbedField(name: post.headline, value: post.src[0].url))

  embed.fields = some fields

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
