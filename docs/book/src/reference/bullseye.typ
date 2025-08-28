#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"
#import "@preview/tidy:0.4.3"

#import "../../book.typ": book-page

#show: book-page.with(title: [`bullseye`])

#let module = tidy.parse-module(
  read("/src/lib.typ"),
  name: "bullseye",
  label-prefix: none,
  // scope: scope,
  // preamble: preamble,
)

#tidy.show-module(
  module,
  show-module-name: false,
  sort-functions: none,
)
