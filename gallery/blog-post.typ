#import "/src/lib.typ": *

#set document(date: none)

#show: show-target(paged: doc => {
  set page(height: auto)

  import "@preview/codly:1.3.0"
  show: codly.codly-init
  doc
})

#show image: show-target(html: img => {
  html.elem("img", attrs: ("src": img.source, "alt": img.alt))
})

#show raw.where(block: true): show-target(html: code => {
  html.elem("pre", attrs: ("class": "language-" + code.lang), code)
})

#let back-to-top = html.elem("a", attrs: (href: "#"))[(back to top)]

= My blog post

#lorem(5)

#figure(
  image("image.svg", alt: "a rectangle"),
  caption: [A rectangle]
)

#lorem(5)

```typ
#let x = 0
```

#context on-target(html: back-to-top)
