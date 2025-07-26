// test case targeting any output, potentially without support for HTML
#import "/src/lib.typ" as bullseye
#import bullseye: target, html

Hello World #context target()

// calling html functions even without having checked the target
#let test-div = html.elem("div")[Test]
// only rendering html when target is correct
#context if target() == "html" { test-div }

// rendering of html won't work on the wrong target
// #context if target() != "html" { test-div }
