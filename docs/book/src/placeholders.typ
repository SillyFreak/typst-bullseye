#import "@preview/shiroa:0.2.3": *
#import "@preview/codly:1.3.0"

#import "../book.typ" as man-style: ref-fn, blog-post-raw, book-page

#show: book-page.with(title: [Experimental feature placeholders])

Typst's #link("https://staging.typst.app/docs/reference/html/")[`html` module] and the #link("https://staging.typst.app/docs/reference/foundations/target/")[`target()` function] for determining the kind of output are currently unstable, meaning they can't be used without a feature flag.
In #cross-link("/src/intro.typ", reference: <target-conditional>)[Target-conditional code], we saw how this leads to problems even when compiling to PDF, simply because the document is _prepared_ for HTML output:

```
error: unknown variable: html
   ┌─ blog-post.typ:19:19
   │
19 │ #let back-to-top = html.elem("a", attrs: (href: "#"))[(back to top)]
   │                    ^^^^
```

```
error: unknown variable: target
  ┌─ blog-post.typ:1:25
  │
1 │ #show: doc => context if target() != "html" {
  │                          ^^^^^^
```

Some workarounds for this problem include

- Restructuring the code to only call experimental functions when HTML export is requested.
  This doesn't always make the code more manageable, and note that the `target()` function itself is among the unstable functions.

- Requiring the user to always enable HTML support:
  ```
  $ typst compile --features html blog-post.typ
  ```
  This is especially annoying when writing packages for people who may or may not be interested in HTML export.
  Also, this requires different approaches for plain CLI compilation (demonstrated above), Tinymist users, or web app users (not supported),

For this reason, Bullseye polyfills
#footnote[a #link("https://en.wikipedia.org/wiki/Polyfill_%28programming%29")[polyfill] is #quote[code that implements a new standard feature of a deployment environment within an old version of that environment]]
the #ref-fn("target()") function when HTML support is not enabled,
and contains a stub
#footnote[a #link("https://en.wikipedia.org/wiki/Method_stub")[stub], in this case of a module instead of a method, is #quote[a short and simple placeholder [that] contains just enough code to allow it to be used]]
#man-style.show-reference(<mod-html>, "html") module that allows compiling code _creating_ but not _rendering_ HTML elements.
These features were used in the previous examples, as they were included in this wildcard import:

#codly.codly(range: (1, 1), smart-skip: false)
#blog-post-raw

Whether the placeholders or the real Typst code is executed depends on whether the HTML feature is enabled:

- HTML support is not enabled: Bullseye's placeholders are used.
  The #ref-fn("target()") function always returns `"paged"` (which is correct when HTML export isn't supported),
  and the #ref-fn("html.elem()") and #ref-fn("html.frame()") functions don't do anything useful.
  If you tried to unconditionally put an HTML element such as `back-to-top` into your document, it would panic.

- HTML support is enabled: Bullseye's exports simply forward to the standard ones.
  The #ref-fn("target()") function returns the same result as #link("https://staging.typst.app/docs/reference/foundations/target/")[`std.target()`],
  and #ref-fn("html") is an exact alias to #link("https://staging.typst.app/docs/reference/html/")[`std.html`].
  This is is independent from the export _target_, but it usually won't make a difference if not exporting to HTML.

There is one small difference between the stubbed and original #ref-fn("html") module:
when not exporting to HTML, if a #link("https://staging.typst.app/docs/reference/html/elem/")[`std.html.elem()`] appears in the document, it will result in a warning; Bullseye's #ref-fn("html.elem()") will panic instead!
