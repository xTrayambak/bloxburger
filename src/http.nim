import std/[httpclient, json], jsony

proc fetchJson*(url: string): JsonNode =
  let httpClient = newHTTPClient()
  let data = httpClient.getContent(url)

  jsony.fromJson(data).getElems()[0]

proc fetchHttp*(url: string): string =
  let httpClient = newHTTPClient()
  httpClient.getContent(url)
