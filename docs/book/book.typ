#import "@preview/shiroa:0.2.3": *
#show: book

#book-meta(
  title: "Bullseye",
  description: "Bullseye Typst package documentation",
  repository: "https://github.com/SillyFreak/typst-bullseye",
  authors: ("SillyFreak",),
  language: "en",
  summary: [ // this field works like summary.md of mdbook
    #prefix-chapter("src/intro.typ")[Introduction]

    = More
    - #chapter("src/more.typ")[More]
      - #chapter("src/details.typ")[Details]
    - #chapter(none)[Even more]
  ]
)
