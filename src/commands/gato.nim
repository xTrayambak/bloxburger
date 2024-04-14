# gato arabe moment
# keyboard cat my beloved
import
  std/[colors, json, options, asyncdispatch, strutils],
  dimscord,
  chronicles,
  librng,
  ../[assets, coloring, http]

var rng = newRNG(algo=Xoroshiro128StarStar)

const
  API_URL* = "https://api.thecatapi.com/v1/images/search"
  GATO_QUOTES* = [
    "\"no one like me, no one like me!\" :(", "\"halooo hooman, can i hev milch?\"",
    "\"us cats r far superior 2 dogs! do u agree?!\"",
    "\"that guy tray is a big, dumb doodoo head!!!!\""
  ]

proc gatoGenerator*(bot: DiscordClient, m: Message) {.async.} =
  info "Fetching gatos!", url = API_URL

  let
    msg =
      waitFor bot.api.sendMessage(
        m.channelId,
        ":arrows_clockwise: Fetching the cutest gatos for you! :arrows_clockwise:",
      )

  var req: JsonNode
  try:
    req = fetchJson API_URL
  except CatchableError as exc:
    error "Gato generator ran into an error.", err=exc.msg
    discard await bot.api.sendMessage(
      m.channelId,
      embeds = @[
        Embed(
          title: some ":x: Failed to fetch gato list.",
          description: some "Traceback: ```" & exc.msg & "```",
          footer: some EmbedFooter(text: "Report this to Tray! :(", iconUrl: some CAT_NOD_GIF),
          color: some red()
        )
      ]
    )
    return

  let embed =
      Embed(
        title: some "Here's a cute gato for you!",
        description: some rng.choice(GATO_QUOTES),
        image: some EmbedImage(url: req["url"].getStr()),
        footer:
          some EmbedFooter(
            text:
              "Please don't spam this command or else we get banned from the Gato Generating Machine! :(",
            iconUrl: some CAT_NOD_GIF,
          ),
        color: randColor()
      )

  discard await bot.api.sendMessage(m.channelId, embeds = @[embed])
  await bot.api.deleteMessage(msg.channelId, msg.id)
