#import "@preview/shiroa:0.2.3": *
#import "@preview/codly:1.3.0"

#import "../book.typ" as man-style: ref-fn, blog-post-raw

= Simplifying target-specific Typst <simplifying>

When targeting both PDF and HTML, it's unavoidable to have some content that must be treated differently depending on the output format.
This resulted in two fundamental pain points:

- Since Typst's HTML support and target switching in general are still unstable, the necessary functions to write this code are not always available. This problem will eventually go away.

- The necessary conditionals can lead to unwieldy code that is hard to read and write.

Bullseye tackles both of these problems. Let's look at some specific issues from the blog post example:

== Applying target-specific show rules <show-rules>

The original blog post contained the following rules that shouldn't be active for the HTML target:

#codly.codly(ranges: ((2, 2), (4, 5)), smart-skip: false)
#raw(block: true, lang: "typ", read("/gallery/no-gallery/naive-blog-post.typ"))

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

#codly.codly(ranges: ((1, 2), (5, 11)), smart-skip: false)
#blog-post-raw

The template function is wrapped and passed as a named argument `paged`, meaning the show rule is only applied if the output format is PDF or one of the image formats.
Multiple arguments can be specified, to apply different show rules for different formats.

This function can also be used to style specific elements, not just for document-wide settings.
The following show rules from #cross-link("/src/intro.typ", reference: <target-conditional>)[Target-conditional code] were put into a block to only be applied for HTML output:

#codly.codly(ranges: ((1, 1), (4, 4), (6, 9), (16, 16)), smart-skip: false)
#raw(block: true, lang: "typ", read("/gallery/no-gallery/manual-blog-post.typ"))

Instead of moving both show rules into one shared conditional, #ref-fn("show-target()") makes it painless to individually apply them where you want to have them in your template:

#codly.codly(ranges: ((13, 15), (17, 19)), smart-skip: false)
#blog-post-raw

== Producing target-specific content <content>

One of the "features" of the blog post was a "back to top" link produced in the HTML output.
To conditionally produce this link, the document contained the following code:

#codly.codly(range: (36, 36), smart-skip: false)
#raw(block: true, lang: "typ", read("/gallery/no-gallery/manual-blog-post.typ"))

This isn't too complex, but Bullseye also has a utility function #ref-fn("on-target()") for producing a value only for some output formats, and `none` for others:

#codly.codly(range: (38, 38), smart-skip: false)
#blog-post-raw

This mirrors the structure for show rules.
Like #ref-fn("show-target()"), #ref-fn("on-target()") can also accept multiple named arguments.

Both these functions are built on top of #ref-fn("match-target()"), which you can use if you have target-specific functionality that doesn't fit the show rule or extra content cases.
