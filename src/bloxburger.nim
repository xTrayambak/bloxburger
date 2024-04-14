import
  std/[asyncdispatch, strutils, os, options, tables],
  dimscord,
  dimscmd,
  chronicles,
  utils,
  jsony,
  ./coloring,
  commands/[questions, news, debug, gato, doggo, math_eval, loremipsum]

let
  discord =
    newDiscordClient(
      getEnv("DISCORD_TOKEN")
    )

var
  cmd = discord.newHandler()

  afkPeople = newTable[string, string]()

if fileExists("afk.json"):
  afkPeople = readFile("afk.json").fromJson(TableRef[string, string])

# Handle event for on_ready.
proc onReady(s: Shard, r: Ready) {.event(discord).} =
  info "Connected to Discord"

  await s.updateStatus(
    activity = some ActivityStatus(name: "Custom Status", state: some "Woohoo!", kind: atCustom), 
    status = "idle"
  )

proc messageReactionAdd(s: Shard, m: Message, u: User, em: Emoji, exists: bool) {.event(discord).} =
  discard await discord.api.sendMessage(m.channelId, "meow :3")

# Handle event for message_create.
proc messageCreate(s: Shard, m: Message) {.event(discord).} =
  if m.author.bot:
    return

  if m.author.id in afkPeople:
    info "Revoking AFK status", user=m.author, reason=afkPeople[m.author.id]
    discard await discord.api.sendMessage(
      m.channelId,
      embeds = @[
        Embed(
          title: some "Welcome back, **" & $m.author & "**!",
          description: some "You were gone for \"**" & afkPeople[m.author.id] & "**\".",
          color: randColor()
        )
      ]
    )
    afkPeople.del(m.author.id)

  echo '[' & $m.author & "]: " & m.content

  discard await cmd.handleMessage(">", s, m)

cmd.addChat("create question") do(m: Message):
  discard createQuestion(discord, m, m.content.split(">create question ")[1])

cmd.addChat("solve question") do(m: Message, id: string, question: seq[string]):
  discard solveQuestion(discord, m, id, question.join(" "))

cmd.addChat("political news") do(m: Message):
  await getPoliticalNews(discord, m)

cmd.addChat("gato") do(m: Message):
  await gatoGenerator(discord, m)

cmd.addChat("afk") do(m: Message, reason: string = "No reason provided."):
  info "Setting status as AFK", user=m.author, reason=reason
  afkPeople[m.author.id] = reason
  discard await discord.api.sendMessage(
    m.channelId,
    embeds = @[
      Embed(
        title: some "**Setting your status as AFK**",
        description: some "\"**" & reason & "**\"",
        color: randColor()
      )
    ]
  )

cmd.addChat("doggo") do(m: Message):
  await doggoGenerator(discord, m)

cmd.addChat("doggo regenerate") do(m: Message):
  await doggoRegenerate(discord, m)

cmd.addChat("evaluate") do(m: Message, expression: string, variables: seq[string]):
  await mathEval(discord, m, expression, variables)

cmd.addChat("debugger") do(m: Message):
  await debugCmd(discord, m)

cmd.addChat("lorem ipsum") do(m: Message, mode: string = "line"):
  await loremIpsum(discord, m, mode)

cmd.addChat("list questions") do(m: Message):
  await listQuestions(discord, m)

# Connect to Discord and run the bot.
waitFor discord.startSession()

writeFile(
  "afk.json",
  jsony.toJson(afkPeople)
)
