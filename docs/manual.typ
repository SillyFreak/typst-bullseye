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

This package consists of two parts:
- At the foundation, it contains a wrapper around the currently unstable Typst features for target detection and HTML output.
- Built on top of that are a few helpful functions that allow package and document authors to easily write content and show rules that behave differently based on the target.

This document will start with an example blog post as a use case and demonstrate the problems of multi-target documents,
then look at the helper functions in @simplifying as it is more immediately important to users, and then use that to motivate the foundation described in @placeholders.

== A hypothetical blog post <blog-post>

Let's say you're writing a fairly simple blog.
You draft a Typst document with its content, which looks roughly like this:

#raw(block: true, lang: "typ", read("../gallery/no-gallery/naive-blog-post.typ"))

this is still incomplete, but looks good in the preview.
You then try to compile it to HTML:

```
$ typst compile --features html --format html blog-post.typ
...
error: page configuration is not allowed inside of containers
  ┌─ blog-post.typ:2:1
  │
2 │ #set page(height: auto)
  │  ^^^^^^^^^^^^^^^^^^^^^^
```

That didn't work, but since `set page` is just for the preview, you can just remove this line and try again:

```
$ typst compile --features html --format html blog-post.typ
...
warning: block was ignored during HTML export
   ┌─ blog-post.typ:12:2
   │
12 │   image("image.svg", alt: "a rectangle"),
   │   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
warning: block was ignored during HTML export
     ┌─ @preview/codly:1.3.0/src/lib.typ:1744:8
     │
1744 │ ╭         grid(
1745 │ │           columns: if has-annotations {
     · │
1780 │ │           ..footer,
1781 │ │         )
     │ ╰─────────^
```

It compiles with some important warnings: the resulting HTML file has no image and no code!

```html
<h2>My blog post</h2>
<p>Lorem ipsum dolor sit amet.</p>
<figure>
  <figcaption>Figure 1: A rectangle</figcaption>  <!-- oops! -->
</figure>
<p>Lorem ipsum dolor sit amet.</p>
<div></div>  <!-- oops! -->
<p>(back to top)</p>  <!-- not a lik yet -->
```

== Target-conditional code <target-conditional>

Our issue boils down to us wanting to conditionally apply certain styling and content.
Typst's #link("https://staging.typst.app/docs/reference/foundations/target/")[`target()` function] can be used to (contextually) determine what kind of output some content is rendered in.
Using that, you could rewrite your code like this (this is the code Bullseye will subsequently simplify, so feel free to only skim it):

#codly.codly(ranges: ((none, 21), (36, none)), smart-skip: true)
#raw(block: true, lang: "typ", read("../gallery/no-gallery/manual-blog-post.typ"))

That's quite a bit of code, but ...

```
$ typst compile --features html --format html blog-post.typ
warning: html export is under active development and incomplete
```

... there's only the generic "unstable feature" warning, and the HTML looks reasonable too:

```html
<h2>My blog post</h2>
<p>Lorem ipsum dolor sit amet.</p>
<figure>
  <img src="image.svg" alt="a rectangle">
  <figcaption>Figure 1: A rectangle</figcaption>
</figure>
<p>Lorem ipsum dolor sit amet.</p>
<pre class="language-typ"><pre>#let x = 0</pre></pre>
<p><a href="#">(back to top)</a></p>
```

_But_ this broke PDF export and the preview:

```
$ typst compile blog-post.typ
error: unknown variable: html
   ┌─ blog-post.typ:19:19
   │
19 │ #let back-to-top = html.elem("a", attrs: (href: "#"))[(back to top)]
   │                    ^^^^
```

And even if we fixed _that_:

```
error: unknown variable: target
  ┌─ blog-post.typ:1:25
  │
1 │ #show: doc => context if target() != "html" {
  │                          ^^^^^^
```

What now?

... enter Bullseye

= Simplifying target-specific Typst <simplifying>

When targeting both PDF and HTML, it's unavoidable to have some content that must be treated differently depending on the output format.
This resulted in two fundamental pain points:

- Since Typst's HTML support and target switching in general are still unstable, the necessary functions to write this code are not always available. This problem will eventually go away.

- The necessary conditionals can lead to unwieldy code that is hard to read and write.

Bullseye tackles both of these problems. Let's look at some specific issues from the blog post example:

== Applying target-specific show rules <show-rules>

#let blog-post-raw = context crudo.map(
  raw(block: true, lang: "typ", read("../gallery/blog-post.typ")),
  line => line.replace("/src/lib.typ", package-import-spec()),
)

The original blog post contained the following rules that shouldn't be active for the HTML target:

#codly.codly(ranges: ((2, 2), (4, 5)), smart-skip: false)
#raw(block: true, lang: "typ", read("../gallery/no-gallery/naive-blog-post.typ"))

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
The following show rules from @target-conditional were put into a block to only be applied for HTML output:

#codly.codly(ranges: ((1, 1), (4, 4), (6, 9), (16, 16)), smart-skip: false)
#raw(block: true, lang: "typ", read("../gallery/no-gallery/manual-blog-post.typ"))

Instead of moving both show rules into one shared conditional, #ref-fn("show-target()") makes it painless to individually apply them where you want to have them in your template:

#codly.codly(ranges: ((13, 15), (17, 19)), smart-skip: false)
#blog-post-raw

== Producing target-specific content <content>

One of the "features" of the blog post was a "back to top" link produced in the HTML output.
To conditionally produce this link, the document contained the following code:

#codly.codly(range: (36, 36), smart-skip: false)
#raw(block: true, lang: "typ", read("../gallery/no-gallery/manual-blog-post.typ"))

This isn't too complex, but Bullseye also has a utility function #ref-fn("on-target()") for producing a value only for some output formats, and `none` for others:

#codly.codly(range: (38, 38), smart-skip: false)
#blog-post-raw

This mirrors the structure for show rules.
Like #ref-fn("show-target()"), #ref-fn("on-target()") can also accept multiple named arguments.

Both these functions are built on top of #ref-fn("match-target()"), which you can use if you have target-specific functionality that doesn't fit the show rule or extra content cases.

= Experimental feature placeholders <placeholders>

Typst's #link("https://staging.typst.app/docs/reference/html/")[`html` module] and the #link("https://staging.typst.app/docs/reference/foundations/target/")[`target()` function] for determining the kind of output are currently unstable, meaning they can't be used without a feature flag.
In @target-conditional, we saw how this leads to problems even when compiling to PDF, simply because the document is _prepared_ for HTML output:

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

#pagebreak()

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
