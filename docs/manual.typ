#import "template.typ" as template: *
#import "/src/lib.typ" as bullseye

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

...

= Module reference

#module(
  read("/src/lib.typ"),
  name: "bullseye",
  label-prefix: none,
)
