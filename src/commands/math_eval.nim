import std/[asyncdispatch, options, strutils, tables], dimscord, chronicles, algebra

# x+y=3 where x=3,y=0
# 1+1

proc mathEval*(
    bot: DiscordClient, m: Message, expression: string, variables: seq[string]
) {.async.} =
  echo "expr = " & expression
  info "Evaluating expression", expr = expression

  var values = initTable[string, float]()

  for v in variables:
    let s = v.split('=')
    let k = s[0]
    let val = s[1]

    try:
      values[k] = val.parseFloat()
    except CatchableError as exc:
      discard await bot.api.sendMessage(
          m.channelId,
          embeds =
            @[
              Embed(
                title: some "Failed to evaluate number \"" & val & "\"",
                description:
                  some exc.msg &
                    ": you either threw random shit at the evaluator and expected miracles to happen, or tray's shitty code fell flat on its face. 50/50 chances. :P",
              )
            ],
        )
      return

  var res: float

  try:
    res = evaluate(expr(expression), values)
  except CatchableError as exc:
    discard await bot.api.sendMessage(
        m.channelId,
        embeds =
          @[
            Embed(
              title: some "Failed to evaluate expression \"" & expression & "\"",
              description:
                some exc.msg &
                  ": you either threw random shit at the evaluator and expected miracles to happen, or tray's shitty code fell flat on its face. 50/50 chances. :P",
            )
          ],
      )
  discard await bot.api.sendMessage(
      m.channelId,
      embeds =
        @[
          Embed(
            title: some "**Statement Evaluation Result**",
            description: some "**" & $res & "**",
          )
        ],
    )
