#import "template.typ" as template: *
#import "/src/lib.typ" as bullseye

#import "@preview/crudo:0.1.1"

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: [Bullseye],
  subtitle: [Hit the target (HTML or paged/PDF) when styling your Typst document],
  date: none,
  // date: datetime(year: ..., month: ..., day: ...),

  // logo: rect(width: 5cm, height: 5cm),
  // abstract: [
  //   A PACKAGE for something
  // ],

  scope: (bullseye: bullseye),
)

= Introduction

Bullseye supports you in writing packages and documents that target multiple outputs, i.e. currently (Typst 0.13) `"paged"` (PDF, image) and `"html"`.

== Experimental feature polyfills

Typst's #link("https://staging.typst.app/docs/reference/html/")[`html` module] and the #link("https://staging.typst.app/docs/reference/foundations/target/")[`target()` function] for determining the kind of output are currently unstable, meaning they can't be used without a feature flag.
This is an obstacle for packages and documents that want to optionally support HTML output;
suppose you need some separate content for the two formats, and so you may write some code like this:

````typ
// for PDF output, Typst handles syntax highlighting
#let snippet = ```py
def x(): pass
```
// for HTML output, syntax highlighting is added externally through a CSS class
#let html-snippet = html.elem("code", attrs: (class: "lang-py"), snippet.text)

// conditionally render either of these
#context if target() == "html" {
  html-snippet
} else {
  snippet
}
````

However, compiling this will result in an error:

```
$ typst compile test.typ
error: unknown variable: html
  │ #let html-snippet = html.elem("code", attrs: (class: "lang-py"), snippet.text)
  │                     ^^^^
```

Even though the current export target is pdf, the fact that we have not enabled HTML support makes this code fail!
Some workarounds for this problem include

- Restructure the code to only call experimental functions when HTML export is requested.
  This doesn't always make the code more manageable, and note that the `target()` function itself is among the unstable functions.

- Require the user to always enable HTML support:
  ```
  $ typst compile --features html test.typ
  ```
  This is especially annoying when writing packages for people who may or may not be interested in HTML export.
  Also, this requires different approaches for plain CLI compilation (demonstrated above), Tinymist users, or web app users (not supported),

For this reason, Bullseye "polyfills" the #ref-fn("target()") function when HTML support is not enabled,
and contains a stub #man-style.show-reference(<mod-html>, "html") module that allows compiling code _calling_ but not _rendering_ HTML elements:

#context crudo.join(
  main: -1,
  crudo.map(
    ```typ
    #import "PACKAGE": target, html
    ```,
    line => line.replace("PACKAGE", package-import-spec()),
  ),
  ```typ
  #let snippet = /* ... */
  #let html-snippet = html.elem(/* ... */)
  #context if target() == "html" { /* ... */ }
  ```,
)

There are two scenarios in which this code can be executed:

- HTML support is not enabled: Bullseye's polyfills are used.
  The #ref-fn("target()") function always returns `"paged"`,
  and the #ref-fn("html.elem()") and #ref-fn("html.frame()") functions don't do anything useful.
  If you tried to unconditionally put `html-snippet` into your document, it would panic.

- HTML support is enabled: Bullseye's exports simply forward to the standard ones.
  The #ref-fn("target()") function returns the same result as #link("https://staging.typst.app/docs/reference/foundations/target/")[`std.target()`],
  and #ref-fn("html") is an exact alias to #link("https://staging.typst.app/docs/reference/html/")[`std.html`].
  This is is independent from the export _target_, but it usually won't make a difference if not exporting to HTML.

There is one small difference between the polyfilled and original #ref-fn("html") module:
when not exporting to HTML, the if an original #link("https://staging.typst.app/docs/reference/html/elem/")[`std.html.elem()`] appears in the document, it will result in a warning; Bullseye's #ref-fn("html.elem()") will panic instead!

= Module reference

#module(
  read("/src/lib.typ"),
  name: "bullseye",
  label-prefix: none,
)

== `bullseye.html` <mod-html>

#module(
  read("/src/html.typ"),
  name: "bullseye.html",
  show-module-name: false,
  label-prefix: "html",
)
