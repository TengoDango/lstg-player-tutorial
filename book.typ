#import "@preview/shiroa:0.3.0": *
#import templates: heading-reference

#show: book

#let prefix = "lstg-player-tutorial"
// #let prefix = "."
#book-meta(
  title: "何日完工?",
  authors: ("TengoDango",),
  repository: "https://github.com/TengoDango/lstg-player-tutorial/",
  summary: [
    #prefix-chapter("appendix/preface.typ")[没人看的序言]

    = 从零开始的写自机之旅
    #chapter("mainline/beginning.typ")[那么从哪里开始呢]

    = 我要翻 data!
    #chapter(prefix + "/dataer/if-you-want-it.typ", section: "0")[如果你想要, 你得自己来拿]
    #chapter(prefix + "/dataer/player.typ")[`player.lua` 解析]
    #chapter(prefix + "/dataer/player-system.typ")[`player_system.lua` 解析]
    #chapter(prefix + "/dataer/wisys.typ")[`PlayerWalkImageSystem` 解析]
    #chapter(prefix + "/dataer/others.typ")[杂项]

    = 没人看的附录
    #suffix-chapter(prefix + "/appendix/lstg-gameobject.typ")[`lstg.GameObject.lua`]
    #suffix-chapter(prefix + "/appendix/player-lua.typ")[`player.lua`]
    #suffix-chapter(prefix + "/appendix/player-system-lua.typ")[`player_system.lua`]
    #suffix-chapter(prefix + "/appendix/wisys-lua.typ")[`PlayerWalkImageSystem`]
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
  show figure: set align(center)

  show strong: set text(blue)

  content
}

#let cross-ref(path, reference: none, content) = cross-link(
  "/" + prefix + path,
  // path,
  reference: if reference != none {
    heading-reference(reference)
  },
  content,
)

