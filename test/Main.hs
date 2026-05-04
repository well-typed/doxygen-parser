module Main (main) where

import Test.Tasty

import Test.Doxygen.Parser.Block qualified as Block
import Test.Doxygen.Parser.CodeBlock qualified as CodeBlock
import Test.Doxygen.Parser.Comment qualified as Comment
import Test.Doxygen.Parser.InlineNesting qualified as InlineNesting
import Test.Doxygen.Parser.InlineParsing qualified as InlineParsing
import Test.Doxygen.Parser.List qualified as List
import Test.Doxygen.Parser.NormalizeWhitespace qualified as NormalizeWhitespace
import Test.Doxygen.Parser.Param qualified as Param
import Test.Doxygen.Parser.Properties qualified as Properties
import Test.Doxygen.Parser.SimpleSect qualified as SimpleSect
import Test.Doxygen.Parser.StructuralWarnings qualified as StructuralWarnings
import Test.Doxygen.Parser.Whitespace qualified as Whitespace
import Test.Doxygen.Parser.XMLFileResult qualified as XMLFileResult

main :: IO ()
main =
    defaultMain $ testGroup "doxygen-parser"
      [ testGroup "normalizeWhitespace"    NormalizeWhitespace.tests
      , testGroup "inline parsing"         InlineParsing.tests
      , testGroup "inline nesting"         InlineNesting.tests
      , testGroup "whitespace handling"    Whitespace.tests
      , testGroup "block parsing"          Block.tests
      , testGroup "comment parsing"        Comment.tests
      , testGroup "parameter parsing"      Param.tests
      , testGroup "simplesect kinds"       SimpleSect.tests
      , testGroup "list parsing"           List.tests
      , testGroup "code block parsing"     CodeBlock.tests
      , testGroup "structural warnings"    StructuralWarnings.tests
      , testGroup "XMLFileResult assembly" XMLFileResult.tests
      , testGroup "properties"             Properties.tests
      ]
