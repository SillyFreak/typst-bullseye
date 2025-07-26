root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# generate manual
doc:
  typst compile docs/manual.typ docs/manual.pdf
  typst compile docs/thumbnail.typ thumbnail-light.svg
  typst compile --input theme=dark docs/thumbnail.typ thumbnail-dark.svg
  for f in $(find gallery -maxdepth 1 -name '*.typ'); do \
    typst compile "$f"; \
    typst compile --features html --format html "$f"; \
  done

# run test suite
test *args:
  # check that paged export without --features html matches
  tt run -F --max-delta 1 {{ args }}
  # check that paged export with --features html matches
  if \
    A="$(typst compile --features html --format png tests/test1/test.typ - | sha1sum)" && \
    B="$(typst compile --features html --format png tests/test1/ref-feature-html.typ - | sha1sum)" && \
    test "$A" = "$B"; \
  then exit 0; else \
    echo "paged export differes between original and polyfilled code" >&2; \
    exit 1; \
  fi
  # check that html export with --features html matches
  if \
    A="$(typst compile --features html --format html tests/test1/test.typ - | sha1sum)" && \
    B="$(typst compile --features html --format html tests/test1/ref-feature-html.typ - | sha1sum)" && \
    test "$A" = "$B"; \
  then exit 0; else \
    echo "html export differes between original and polyfilled code" >&2; \
    exit 1; \
  fi

# update test cases
update *args:
  tt update {{ args }}

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test doc
