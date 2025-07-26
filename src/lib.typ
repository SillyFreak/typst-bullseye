/// Returns `"paged"` or `"html"` depending on the current output target.
///
/// When HTML is supported, this is equivalent to Typst's built-in
/// #link("https://staging.typst.app/docs/reference/foundations/target/")[`std.target()`]\;
/// otherwise, it always return `"paged"`.
///
/// This is a polyfill for an unstable Typst function. It may not properly emulate the built-in
/// function if it is changed before stabilization.
///
/// This function is contextual.
///
/// -> str
#let target() = {
  if "target" in dictionary(std) { std.target() }
  else { "paged" }
}

/// The `html` module.
///
/// When HTML is supported, this is equivalent to Typst's built-in
/// #link("https://staging.typst.app/docs/reference/html/")[`std.html`]\; otherwise, it's the
/// Bullseye module documented below. That module doesn't _support_ HTML, it just makes sure that
/// calls to the html module that don't end up in a document don't prevent compilation.
///
/// This is a polyfill for an unstable Typst module. It may not properly emulate the built-in
/// module (i.e. miss functions; no functionality beyond that is intended) if it is changed before
/// stabilization.
///
/// -> module
#let html = {
  if "html" in dictionary(std) {
    std.html
  } else {
    import "html.typ"
    html
  }
}
