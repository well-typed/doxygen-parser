# `doxygen-parser`: Parse Doxygen XML output into a typed Haskell AST

[![Build and test](https://github.com/well-typed/doxygen-parser/actions/workflows/haskell.yml/badge.svg)](https://github.com/well-typed/doxygen-parser/actions/workflows/haskell.yml)

`doxygen-parser` is a standalone Haskell library that invokes the
[`doxygen`](https://www.doxygen.nl/) binary on C/C++ header files and
turns its XML output into a typed Haskell AST. It works on any C/C++
headers `doxygen` understands.

## Requirements

The `doxygen` executable must be installed and on `PATH` (or the path
must be supplied through `Doxygen.Parser.Config`). Tested with
`doxygen` 1.15.0; older versions usually work but the XML schema
shifts subtly between releases.

## Quick start

```haskell
import Doxygen.Parser
import Data.List.NonEmpty (NonEmpty (..))

main :: IO ()
main = do
    Result{doxygen, warnings, doxygenVersion} <-
        parse defaultConfig ("myheader.h" :| [])
    putStrLn $ "doxygen version: " ++ show doxygenVersion
    mapM_ print warnings
    -- `doxygen` is opaque; query it with the lookup helpers:
    print $ lookupComment (DoxygenKey "myFunc") doxygen
```

`Result` carries:

  * `doxygen :: Doxygen` — opaque map of `DoxygenKey` to comment trees,
    queried via `lookupComment`, `lookupGroupMembership`,
    and `lookupGroupInfo`.
  * `warnings :: [Warning]` — non-fatal degradations encountered while
    parsing (unknown elements, malformed refs, etc.).
  * `doxygenVersion :: Text` — the version of the `doxygen` binary
    that was invoked.

If the `doxygen` invocation itself fails, `parse` throws
`DoxygenException`.

## Public modules

| Module                   | Purpose                                       |
| ------------------------ | --------------------------------------------- |
| `Doxygen.Parser`         | Top-level public API. Start here.             |
| `Doxygen.Parser.Types`   | The `Comment` / `Block` / `Inline` AST.       |
| `Doxygen.Parser.Warning` | Warning, `Context`, and `Degradation` types.  |

## Stability

`doxygen-parser` follows the [Haskell Package Versioning
Policy](https://pvp.haskell.org/). The `Doxygen.Parser`,
`Doxygen.Parser.Types`, and `Doxygen.Parser.Warning` modules form the
supported public API; breaking changes there bump the major version
(`A.B`).

## Used by

  * [`hs-bindgen`](https://github.com/well-typed/hs-bindgen) — automatic
    Haskell FFI binding generation from C headers.

## License

BSD-3-Clause. Copyright Well-Typed LLP and Anduril Industries Inc.
See [`LICENSE`](./LICENSE).
