#import "@preview/shiroa:0.3.0": *

#show: book

#book-meta(
  title: "LuaSTG 数学基础",
  authors: ("TengoDango",),
  repository: "https://github.com/TengoDango/LstgMathTutorial",
  summary: [
    #prefix-chapter("docs/preface.typ")[前言]
  ],
)



// re-export page template
#import "/templates/page.typ": project
#let book-page = project
