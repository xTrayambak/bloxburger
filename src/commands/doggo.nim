import
  std/[options, strutils, asyncdispatch, httpclient, json, colors],
  dimscord,
  chronicles,
  jsony,
  librng,
  ../assets,
  ../http

var rng = newRNG(algo=Xoroshiro128StarStar)

const
  DOGGO_QUOTES* = [
    "\"woof woof\"", "\"hmm very interesting\"",
    "\"helo hooman, can i hez cheeseborger?\"", "\"wow, such cute, much adore\"",
    "\"can i hez sausage?\""
  ]

proc doggoGenerator*(bot: DiscordClient, m: Message) {.async.} =
  info "Fetching cute doggos"
  let
    msg =
      waitFor bot.api.sendMessage(
        m.channelId,
        ":arrows_clockwise: Fetching the cutest doggos for you! :arrows_clockwise:",
      )
    data = jsony.fromJson(readFile("doggos.json"))

  var randId = rng.choice(data.getElems()).getStr()

  while randId.endsWith(".mp4"):
    randId = rng.choice(data.getElems()).getStr()

  info "Found a cute doggo to display", id = randId

  let
    embed =
      Embed(
        title: some "Here's a cute doggo for you!",
        description: some rng.choice(DOGGO_QUOTES),
        image: some EmbedImage(url: "https://random.dog/" & randId),
        footer: some EmbedFooter(text: "woof", iconUrl: some CAT_NOD_GIF),
        color: some colGreen.int,
      )

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
  await bot.api.deleteMessage(msg.channelId, msg.id)

proc doggoRegenerate*(bot: DiscordClient, m: Message) {.async.} =
  discard waitFor bot.api.sendMessage(
      m.channelId,
      ":dog: Sorting cute floofballs into baskets (**sending HTTP request to API**) :dog:",
    )

  let resp = fetchHttp "https://random.dog/doggos"

  discard await bot.api.sendMessage(
      m.channelId,
      ":dog: Doing a head-count of doggos (**saving JSON data to file, bloxburger will automatically synchronize with this data**) :dog:",
    )

  writeFile("doggos.json", resp)

  discard await bot.api.sendMessage(
      m.channelId,
      ":white_check_mark: All doggos are now up-to-date with the random dogs API! :3 :white_check_mark:",
    )
