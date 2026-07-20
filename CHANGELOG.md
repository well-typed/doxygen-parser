# Revision history for `doxygen-parser`

## ?.?.? -- YYYY-mm-dd

### Breaking changes

### New features

* Support Doxygen custom ALIASES, which allows doc substitution in projects that
  rely on it.

### Minor changes

### Bug fixes

* Parse `title` children with the inline parser so that section headings (`\section`
  or markdown `#`) are no longer dropped.

## 0.1.1 -- 2026-06-21

### New features

* Export `DoxygenKey` from `Doxygen.Parser.Types`. It is still available from
  `Doxygen.Parser` as before.

### Minor changes

* Build `Doxygen.Parser.Types` and `Doxygen.Parser.Warning` as public library
  modules so they get their own Haddock pages. In 0.1.0 they were re-exported
  from a private sub-library, which left them without module pages on Hackage.

## 0.1.0 -- 2026-06-18

* First version. Extracted from
  [`hs-bindgen`](https://github.com/well-typed/hs-bindgen). See
  [hs-bindgen#1884][hs-bindgen-is-1884].

[hs-bindgen-is-1884]: https://github.com/well-typed/hs-bindgen/issues/1884
