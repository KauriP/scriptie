#let titlepage(title: "Unnamed screenplay", author:(), version:none, contact: none, subtitle: none) = {
  set page(foreground: none)
  set document(title: title, author: author, keywords: ("film","movie","screenplay","script"))
  set par(leading: 0em)
  align(center+horizon)[
  #v(1fr)
  *#underline(title)*

  #v(1em)
  by
  #v(-0.5em)
  #author.join("\n")
  #v(0.5em)
  #if version != none [#version\ ]
  #datetime.today().display()
  #v(0.5em)
  #subtitle
  #v(1fr)
  #align(right, contact)
  ]
  pagebreak()
  counter(page).update(1)
}

#let pa(body) = [#[(#body)]<scriptie-parenthetical>]

#let _speaker(name,..extension) = [
    #(upper(name) +
    for ext in extension.pos() {
      [ (#ext)]
    })<scriptie-speaker>
]

#let dialogue(speaker,..extensions, line) = {
// This is a bit hacky...
let c = counter("scriptie-contd")
c.update(0)
let head = context {
  c.step()
  _speaker(speaker, ..(if c.get().first() != 0 {([CONT'D],)} else {()})+extensions.pos())
}
show grid: set block(spacing: 1em)
show grid.cell: set block(spacing: 0pt, sticky: true)
set par(spacing: 0pt, first-line-indent: 1.2em)
[#grid(
grid.header("",head, repeat:true),
"",block(line)
)<scriptie-dialogue>]
}

#let scene(logline) = {
    counter("scriptie-scene").step()
    let number = context numbering("1",counter("scriptie-scene").get().at(0))
    [*#number<scriptie-scene_num_l>#number<scriptie-scene_num_r>#block(sticky:true, above: 3em, below:2em, (upper(logline)))*]
}
#let part(name) = {
    counter("scriptie-part").step()
  [#[\===== Part #(context counter("scriptie-part").get().at(0)): #name =====]<scriptie-part>]
}

#let transition(trans) = {
  block(spacing:1em, width:100%, align(right,strong(upper(trans))))
}

#let plainpage(content,margin:none,header:none) = {
  let header = if header == none {margin==none} else {header}
  set page(foreground: none) if not header
  set page(margin:margin) if margin != none
  pagebreak(weak:true)
  content
  pagebreak(weak:true)
}

#let script(document,
  size:(x:6in,y:9in),
  margin:(left:3fr,right:2fr,top:1fr,bottom:1fr),
  indent:(character:(2in,4in),parenthetical:(1.5in,2.5in),dialogue:(1in,3.5in)),
  scene-numbering: (left:2cm,right:1cm),
  page-numbering: (dx:-1in,dy:0.8in),
  page-size: ("a4",)
) = {
  let margin = {
    let x = 100%-size.x;
    let y = 100%-size.y;
    let wx = margin.left+margin.right;
    let wy = margin.bottom+margin.top;
    (left:x*(margin.left/wx), right:x*(margin.right/wx), top:y*(margin.top/wy), bottom:y*(margin.bottom/wy))
  }
  indent.character.at(0) -= indent.dialogue.at(0)
  indent.parenthetical.at(0) -= indent.dialogue.at(0)

  set page(margin: margin, ..page-size)
  let textsettings = (size:12pt, top-edge: 0.8em, bottom-edge: -0.2em, font:"Courier Prime", weight:"regular")
  set text(..textsettings)
  set par(leading: 0mm, spacing: 1em)
  show heading: set text(..textsettings)
  show heading: set block(spacing: 0pt)
  show raw: set text(..textsettings)
  set page(foreground: if page-numbering != none {place(right,context [#counter(page).get().first().],..page-numbering,)})

  show <scriptie-parenthetical>: it => block(sticky: true, grid(columns: indent.parenthetical,[],it)) //bug #5296
  show <scriptie-speaker>: it => grid(columns:indent.character,[],it)
  show <scriptie-dialogue>: set grid(columns:indent.dialogue)
  show <scriptie-scene_num_r>: it => if scene-numbering.right != none {place(dx:100%+scene-numbering.right,it)} else {[]}
  show <scriptie-scene_num_l>: it => if scene-numbering.left != none {place(dx:-scene-numbering.left,it)} else {[]}
  show <scriptie-part>: it => {
    pagebreak(weak: true)
    align(center, block(above:1in,below:1in, it))
  }
  show "…": "..."
  show "–": "--"
  document
}

#let qscript(
  ..args
  ) = {
  show list.item: it => transition(it.body)
  show terms.item: it => {
    let s = state("scriptie-parse-exts",none)
    s.update(none)
    let ext_re = regex("\s*\((.*?)\)\s*")
    let paren_re = regex("\((.*?)\)")
    show "()": ""
    dialogue(
    {show ext_re: it => {s.update((it.text.match(ext_re).captures.first()))}; it.term},
     (context s.get()),
    {show paren_re: it => pa(it.text.match(paren_re).captures.first())
    it.description})
  }
  show heading.where(level:2): scene
  show heading.where(level:1): it => part(it.body)
  script(..args)
}
