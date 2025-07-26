// reference for the test when targeting any output, requiring support for HTML due to using unstable features
Hello World #context target()

// calling html functions even without having checked the target because HTML is _supported_
#let test-div = html.elem("div")[Test]
// only rendering html when target is correct
#context if target() == "html" { test-div }

// rendering of html produces a warning on the wrong target
// #context if target() != "html" { test-div }
