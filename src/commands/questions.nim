import
  std/[asyncdispatch, json, tables, options, strformat], dimscord, jsony, chronicles, ../coloring

type Question* = seq[Table[string, string]]

const
  FOOTERS =
    {
      "maths": "Mathematicians going to hell because maths is fucking stupid",
      "english": "Oi m8 can i have a bota-uh-wotah",
      "physics":
        "Your mom's mass is too much, but God set her gravity to 0 m/s, so she doesn't have any weight. Problem solved.",
      "biology": "8th graders when they learn how kids are made: :exploding_head:",
      "chemistry": "Jesse, we need to cook.",
      "art-drawing": "Don't fail art school!",
      "computer-science": "0.1 + 0.2 = 0.30000000004",
      "history": "Never won a war, never lost an election\n- Pakistani Armed Forces",
      "civics":
        "Hi, I'm Saul Goodman. Did you know that you have rights? The constitution says you do! And so do I.",
      "geography":
        "I was in class and someone saw a map of France, and questioned why Luxembourg has such a long name for such a small country. I said (with quite good timing I might add) “wait until you see Liechtenstein” and no one laughed. When I make my regular hilarious geography jokes, I expect uproarious laughter from the student body. Is cancel culture ruining my comedy?"
    }.toTable

proc getFooter*(bot: DiscordClient, m: Message): Option[GuildChannel] =
  let channels = waitFor getChannel(bot.api, m.channelId)
  channels[0]

proc createQuestion*(bot: DiscordClient, m: Message, question: string) {.async.} =
  info "Creating a question.", question = question

  var data = readFile("questions.json").fromJson(seq[Table[string, string]])

  let footer = getFooter(bot, m)

  if not footer.isSome:
    error "Command aborted. Can't create question. Channel name is not valid."
    discard await bot.api.sendMessage(
        m.channelId,
        embeds =
          @[
            Embed(
              title: some ":x: **Failed to create question.**",
              description:
                some "You are not allowed to create questions in this channel.",
              color: some red()
            )
          ],
      )
    return

  let id = data.len
  data.add(
    {
      "question": question,
      "asker": m.author.id,
      "solved": "false",
      "solution": "",
      "id": $id
    }.toTable
  )

  discard await bot.api.sendMessage(
      m.channelId,
      embeds =
        @[
          Embed(
            title: some "**" & question & "**",
            description:
              some "Question ID: **" & $id & "**" & "\nWait for someone to answer this.",
            color: randColor(),
            footer: some EmbedFooter(text: FOOTERS[footer.get().name]),
          )
        ],
    )

  info "Registering question."
  writeFile("questions.json", jsony.toJson(data))

  return

proc solveQuestion*(
    bot: DiscordClient, m: Message, id: string, solution: string
) {.async.} =
  var data = readFile("questions.json").fromJson(seq[Table[string, string]])

  let footer = getFooter(bot, m)

  if not footer.isSome:
    error "Could not solve question. Invalid channel."
    discard await bot.api.sendMessage(
        m.channelId,
        embeds =
          @[
            Embed(
              title: some ":x: **Failed to solve question.**",
              description:
                some "You are not allowed to solve questions in this channel.",
              color: randColor()
            )
          ],
      )

  for i, problem in data:
    if problem["id"] == id:
      if problem["solved"] == "true":
        discard await bot.api.sendMessage(
            m.channelId,
            embeds =
              @[
                Embed(
                  title: some ":x: Can't solve this question.",
                  description: some "This question is already solved. Tough luck.",
                )
              ],
          )
        return

      data[i]["solved"] = "true"
      data[i]["solution"] = solution

      discard await bot.api.sendMessage(
          m.channelId,
          embeds =
            @[
              Embed(
                title: some "Solution to problem #" & id,
                description:
                  some "Problem: **" & problem["question"] & "**\n" & "Solution: **" &
                    solution & "**",
                color: randColor(),
                footer: some EmbedFooter(text: FOOTERS[footer.get().name]),
              )
            ],
        )

      writeFile("questions.json", jsony.toJson(data))
      return

  discard await bot.api.sendMessage(
      m.channelId,
      embeds =
        @[
          Embed(
            title: some ":x: Failed to solve question. No such question exists.",
            description: some "Skill issue. Get good.",
          )
        ],
    )

proc listQuestions*(bot: DiscordClient, m: Message) {.async.} =
  let footer = getFooter(bot, m)

  if not footer.isSome:
    discard await bot.api.sendMessage(
      m.channelId,
      embeds = @[
        Embed(
          title: some "**This is not a study-related channel.** >:(",
          color: some red()
        )
      ]
    )

  let quote = FOOTERS[footer.get().name]

  var embed = Embed(
    title: some "**All Questions Ever Asked**",
    color: randColor()
  )

  var 
    data = readFile("questions.json").fromJson(seq[Table[string, string]])
    fields: seq[EmbedField]

  for question in data:
    fields.add(
      EmbedField(
        name: "**" & question["question"] & "**",
        value: if question["solved"] == "true": "Solution: **" & question["solution"] & "**" else: "**Not Solved Yet**"
      )
    )

  embed.fields = some fields

  discard await bot.api.sendMessage(
    m.channelId,
    embeds = @[
      embed
    ]
  )
