#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ" as man-style: ref-fn, blog-post-raw, book-page

#show: book-page.with(title: [Simplifying target-specific Typst])

When targeting both PDF and HTML, it's unavoidable to have some content that must be treated differently depending on the output format.
This resulted in two fundamental pain points:

- Since Typst's HTML support and target switching in general are still unstable, the necessary functions to write this code are not always available. This problem will eventually go away.

- The necessary conditionals can lead to unwieldy code that is hard to read and write.

Bullseye tackles both of these problems. Let's look at some specific issues from the blog post example:

== Applying target-specific show rules <show-rules>

The original blog post contained the following rules that shouldn't be active for the HTML target:

#crudo.lines(
  raw(block: true, lang: "typ", read("/gallery/no-gallery/naive-blog-post.typ")),
  "2-5"
)

Bullseye provides the #ref-fn("show-target()") function for this purpose, which you can use similar to a regular template function.
Here is how the styles above would be extracted to a regular template:

```typ
#show: doc => {
  set page(height: auto)
  import "@preview/codly:1.3.0"
  show: codly.codly-init
  doc
}
```

And here is using #ref-fn("show-target()") for this:

#crudo.lines(
  blog-post-raw,
  "1-11"
)

The template function is wrapped and passed as a named argument `paged`, meaning the show rule is only applied if the output format is PDF or one of the image formats.
Multiple arguments can be specified, to apply different show rules for different formats.

This function can also be used to style specific elements, not just for document-wide settings.
The following show rules from #cross-link("/src/intro.typ", reference: <target-conditional>)[Target-conditional code] were put into a block to only be applied for HTML output:

#crudo.lines(
  raw(block: true, lang: "typ", read("/gallery/no-gallery/manual-blog-post.typ")),
  "1-16"
)

Instead of moving both show rules into one shared conditional, #ref-fn("show-target()") makes it painless to individually apply them where you want to have them in your template:

#crudo.lines(
  blog-post-raw,
  "13-19"
)

== Producing target-specific content <content>

One of the "features" of the blog post was a "back to top" link produced in the HTML output.
To conditionally produce this link, the document contained the following code:

#crudo.lines(
  raw(block: true, lang: "typ", read("/gallery/no-gallery/manual-blog-post.typ")),
  "36"
)

This isn't too complex, but Bullseye also has a utility function #ref-fn("on-target()") for producing a value only for some output formats, and `none` for others:

#crudo.lines(
  blog-post-raw,
  "38"
)

This mirrors the structure for show rules.
Like #ref-fn("show-target()"), #ref-fn("on-target()") can also accept multiple named arguments.

Both these functions are built on top of #ref-fn("match-target()"), which you can use if you have target-specific functionality that doesn't fit the show rule or extra content cases.
