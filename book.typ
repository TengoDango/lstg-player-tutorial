#import "@preview/shiroa:0.3.0": *
#import templates: heading-reference

#show: book

#book-meta(
  title: "何日完工?",
  authors: ("TengoDango",),
  repository: "https://github.com/TengoDango/lstg-player-tutorial/",
  summary: [
    #prefix-chapter("appendix/preface.typ")[没人看的序言]

    = 从零开始的写自机之旅
    #chapter("mainline/beginning.typ")[那么从哪里开始呢]

    = 我要翻 data!
    #chapter("dataer/if-you-want-it.typ", section: "0")[如果你想要, 你得自己来拿]
    #chapter("dataer/player.typ")[`player.lua` 解析]
    #chapter("dataer/player-system.typ")[`player_system.lua` 解析]
    #chapter("dataer/wisys.typ")[`PlayerWalkImageSystem` 解析]
    #chapter("dataer/others.typ")[杂项]

    = 没人看的附录
    #suffix-chapter("appendix/lstg-gameobject.typ")[`lstg.GameObject.lua`]
    #suffix-chapter("appendix/player-lua.typ")[`player.lua`]
    #suffix-chapter("appendix/player-system-lua.typ")[`player_system.lua`]
    #suffix-chapter("appendix/wisys-lua.typ")[`PlayerWalkImageSystem`]
  ],
)

#import "/templates/page.typ": project

#let my_prefix = x-url-base

#let cross-ref(path, reference: none, content) = {
  // Remove .typ extension if present, as HTML files don't have it
  let clean-path = if path.ends-with(".typ") {
    path.slice(0, path.len() - 4)
  } else {
    path
  }
  // Ensure path starts with / for absolute path
  let abs-path = if clean-path.starts-with("/") {
    clean-path
  } else {
    "/" + clean-path
  }
  // cross-link returns a function, content is passed via function call syntax
  cross-link(
    my_prefix + abs-path,
    reference: if reference != none {
      heading-reference(reference)
    },
    my_prefix,
  )
}

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
