#import "@preview/shiroa:0.2.3": *
#import "@preview/codly:1.3.0"

= Introduction

Bullseye supports you in writing packages and documents that target multiple outputs, i.e. currently (Typst 0.13) `"paged"` (PDF, image) and `"html"`.

This package consists of two parts:
- At the foundation, it contains a wrapper around the currently unstable Typst features for target detection and HTML output.
- Built on top of that are a few helpful functions that allow package and document authors to easily write content and show rules that behave differently based on the target.

This document will start with an example blog post as a use case and demonstrate the problems of multi-target documents,
then look at the helper functions in #cross-link("/src/simplifying.typ")[Simplifying target-specific Typst] as it is more immediately important to users, and then use that to motivate the foundation described in #cross-link("/src/placeholders.typ")[Experimental feature placeholders].

== A hypothetical blog post <blog-post>

Let's say you're writing a fairly simple blog.
You draft a Typst document with its content, which looks roughly like this:

#raw(block: true, lang: "typ", read("/gallery/no-gallery/naive-blog-post.typ"))

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
<p>(back to top)</p>  <!-- not a link yet -->
```

== Target-conditional code <target-conditional>

Our issue boils down to us wanting to conditionally apply certain styling and content.
Typst's #link("https://staging.typst.app/docs/reference/foundations/target/")[`target()` function] can be used to (contextually) determine what kind of output some content is rendered in.
Using that, you could rewrite your code like this (this is the code Bullseye will subsequently simplify, so feel free to only skim it):

#codly.codly(ranges: ((none, 21), (36, none)), smart-skip: true)
#raw(block: true, lang: "typ", read("/gallery/no-gallery/manual-blog-post.typ"))

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
