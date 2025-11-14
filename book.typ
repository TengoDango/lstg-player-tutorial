#import "@preview/shiroa:0.3.0": *

#show: book

#book-meta(
  title: "LuaSTG 数学基础",
  authors: ("TengoDango",),
  repository: "https://github.com/TengoDango/LstgMathTutorial",
  summary: [
    #prefix-chapter("docs/preface.typ")[没人看的序言]

    = 从零开始的写自机之旅
    #chapter("docs/mainline/beginning.typ")[那么从哪里开始呢]

    = 我要翻 data!
    #chapter("docs/dataer/if-you-want-it.typ", section: "0")[如果你想要, 你得自己来拿]
    #chapter("docs/dataer/player.typ")[`player.lua` 解析]
    #chapter("docs/dataer/player-system.typ")[`player_system.lua` 解析]
    #chapter("docs/dataer/wisys.typ")[`PlayerWalkImageSystem` 解析]
    #chapter("docs/dataer/others.typ")[杂项]

    = 没人看的附录
    #suffix-chapter("docs/appendix/lstg-gameobject.typ")[`lstg.GameObject.lua`]
    #suffix-chapter("docs/appendix/player-lua.typ")[`player.lua`]
    #suffix-chapter("docs/appendix/player-system-lua.typ")[`player_system.lua`]
    #suffix-chapter("docs/appendix/wisys-lua.typ")[`PlayerWalkImageSystem`]
  ],
)

#import "/templates/page.typ": project

#let book-page(content) = {
  show: project.with(
    authors: "TengoDango",
    title: "自机教程 by 团子",
  )

  show raw.where(block: true): set text(size: 14pt)
  
  show image: set align(center)

  show strong: set text(blue)

  content
}

#let cross-ref(path, reference: none, content) = cross-link(
  "/lstg-player-tutorial" + path,
  // path,
  reference: none,
  content,
)

