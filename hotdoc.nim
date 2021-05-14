import std / [os, macros, strutils, unicode]
include karax / [prelude, kdom]

type
  Item = object
    path: string

    case kind: PathComponent
    of {pcDir, pcLinkToDir}:
      children: seq[Item]
    else:
      content: string

proc renderMarkdown(input: cstring): cstring {.importjs: "md.render(#)".}

proc getFile(kind: PathComponent, path: string): Item =
  result.path = splitPath(path).tail
  result.kind = kind
  case result.kind:
  of {pcDir, pcLinkToDir}:
    for k, childPath in walkDir(path):
      result.children.add getFile(k, childPath)
  else:
    result.content = readFile(path)

proc drawItem(item: Item, printName = true): VNode =
  result = buildHtml(tdiv):
    case item.kind:
    of {pcDir, pcLinkToDir}:
      if printName: a(class="title", href = "#" & replace(item.path, ".md" , "")): text replace(item.path, ".md" , "").capitalize
      for child in item.children:
        drawItem(child)
    else:
      a(class = "section", href="#" & replace(item.path, ".md" , "")):
        text replace(item.path, ".md" , "").capitalize


proc drawMd(item: Item, printName = true): VNode =
  result = buildHtml(tdiv):
    case item.kind:
    of {pcDir, pcLinkToDir}:
      if printName: h1(class="title", id = item.path): text item.path.capitalize
      for child in item.children:
        drawMd(child)
    else:
      tdiv(class = "content-div"):
        h2(id =  replace(item.path, ".md" , "")):
          text replace(item.path, ".md" , "").capitalize
        tdiv:
          verbatim(item.content.renderMarkdown())


proc createDom: VNode =
  const root = getFile(pcDir, getProjectPath() & "/contents")

  result = buildHtml():
    body:
      tdiv(class = "container clear"):
        tdiv(class = "row wrapper"):
          tdiv(class = "toc"):
            span(class = "logo"):
              text "Hotdoc"
              text "®"
            span(class = "switch"):
              button:
                text "🌞🌚"
                proc onclick() =
                  document.body.classList.toggle("dark")
                  document.querySelector("#ROOT").classList.toggle("dark")
            drawItem(root, printName=false)
          tdiv(class = "content"):
            drawMd(root, printName=false)
      footer(class = "container row"):
        text "👑 Made with "
        a(href = "https://github.com/willyboar/hotdoc"):
          text "Hotdoc"
        text " 🌭.\n     "
        a(href="#", class="button"):
          text "⬆"

proc main =
  setRenderer createDom

asm """
var script = document.createElement('script')
script.onload = function () {
  window.md = new Remarkable()
  `main`()
}
script.src = "https://cdn.jsdelivr.net/remarkable/1.7.1/remarkable.min.js"
document.head.appendChild(script)
"""

