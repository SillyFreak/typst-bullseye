// there are no page breaks on the web
#set page(height: auto)
// make code pretty in the preview; the blog platform has JS-based code styling
#import "@preview/codly:1.3.0"
#show: codly.codly-init

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

// in HTML, this should be a link with `href="#"`, which navigates back up
(back to top)
