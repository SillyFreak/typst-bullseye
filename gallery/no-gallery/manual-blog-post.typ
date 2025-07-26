#show: doc => context if target() == "html" {
  // apply this styling for html output:
  // replace rendered images with <img> tags
  show image: img => html.elem("img", attrs: ("src": img.source, "alt": img.alt))
  // instead of using codly, wrap code in a <pre class="language-..."> element
  show raw.where(block: true): code => {
    html.elem("pre", attrs: ("class": "language-" + code.lang), code)
  }
  doc
} else {
  // apply this styling for "regular" output:
  set page(height: auto)
  import "@preview/codly:1.3.0"
  show: codly.codly-init
  doc
}

// a link that can be used at the bottom of the post
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

#context if target() == "html" { back-to-top }
