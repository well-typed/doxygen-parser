module Test.Doxygen.Parser.InlineNesting (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "bold inside emphasis" $
      "<emphasis><bold>text</bold></emphasis>"
        `inlineShouldBe` [Emph [Bold [Text "text"]]]
  , testCase "code inside bold" $
      "<bold><computeroutput>code</computeroutput></bold>"
        `inlineShouldBe` [Bold [Mono [Text "code"]]]
  , testCase "3-deep nesting: bold > emphasis > mono" $
      "<bold><emphasis><computeroutput>deep</computeroutput></emphasis></bold>"
        `inlineShouldBe` [Bold [Emph [Mono [Text "deep"]]]]
  , testCase "nested emphasis" $
      "<emphasis>outer <emphasis>inner</emphasis> outer</emphasis>"
        `inlineShouldBe`
          [Emph [Text "outer ", Emph [Text "inner"], Text " outer"]]
  , testCase "ref inside emphasis" $
      "<emphasis><ref refid=\"x\">name</ref></emphasis>"
        `inlineShouldBe` [Emph [Ref (DoxyRef "name" Nothing) "name"]]
  , testCase "link inside bold" $
      "<bold><ulink url=\"http://x\">text</ulink></bold>"
        `inlineShouldBe` [Bold [Link [Text "text"] "http://x"]]
  , testCase "mixed siblings: text + bold + text + emphasis" $
      "Hello <bold>world</bold> and <emphasis>more</emphasis>!"
        `inlineShouldBe`
          [ Text "Hello ", Bold [Text "world"]
          , Text " and ", Emph [Text "more"]
          , Text "!"
          ]
  ]
