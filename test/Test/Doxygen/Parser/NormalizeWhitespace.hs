module Test.Doxygen.Parser.NormalizeWhitespace (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser.Internal (normalizeWhitespace)

tests :: [TestTree]
tests =
  [ testCase "plain text"                     $ normalizeWhitespace "hello"          @?= "hello"
  , testCase "preserves trailing space"       $ normalizeWhitespace "hello "         @?= "hello "
  , testCase "preserves leading space"        $ normalizeWhitespace " hello"         @?= " hello"
  , testCase "preserves both"                 $ normalizeWhitespace " hello "        @?= " hello "
  , testCase "collapses internal whitespace"  $ normalizeWhitespace "hello   world"  @?= "hello world"
  , testCase "collapses newlines"             $ normalizeWhitespace "hello\n  world" @?= "hello world"
  , testCase "leading newline becomes space"  $ normalizeWhitespace "\n  hello"      @?= " hello"
  , testCase "trailing newline becomes space" $ normalizeWhitespace "hello\n"        @?= "hello "
  ]
