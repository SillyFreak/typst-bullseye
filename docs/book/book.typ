#import "@preview/crudo:0.1.1"
#import "@preview/shiroa:0.2.3": *
#show: book

#let ref-fn(body) = raw(body)
#let show-reference(lbl, body) = raw(body)

#let blog-post-raw = {
  let meta = toml("/typst.toml").package
  let package-import-spec(namespace: "preview") = {
    "@" + namespace + "/" + meta.name + ":" + meta.version
  }
  crudo.map(
    raw(block: true, lang: "typ", read("/gallery/blog-post.typ")),
    line => line.replace("/src/lib.typ", package-import-spec()),
  )
}

#show: summary => book-meta(
  title: "Bullseye",
  description: "Bullseye Typst package documentation",
  repository: "https://github.com/SillyFreak/typst-bullseye",
  authors: ("SillyFreak",),
  language: "en",
  summary: summary,
)

#prefix-chapter("src/intro.typ")[Introduction]

- #chapter("src/simplifying.typ")[Simplifying target-specific Typst]
- #chapter("src/placeholders.typ")[Experimental feature placeholders]
