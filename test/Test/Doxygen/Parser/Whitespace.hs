module Test.Doxygen.Parser.Whitespace (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "space between text and bold is preserved" $
      "Hello <bold>world</bold>"
        `inlineShouldBe` [Text "Hello ", Bold [Text "world"]]

  , testCase "space after bold is preserved" $
      "<bold>word</bold> rest"
        `inlineShouldBe` [Bold [Text "word"], Text " rest"]

  , testCase "inter-element spacing in sentence" $
      "Use <computeroutput>foo</computeroutput> for bar"
        `inlineShouldBe` [Text "Use ", Mono [Text "foo"], Text " for bar"]

  , testCase "whitespace-only text node is normalized to space" $
      "   " `inlineShouldBe` [Text " "]
  , testCase "newline-only text is normalized to space" $
      "\n  \n" `inlineShouldBe` [Text " "]
  , testCase "unicode content preserved" $
      "caf\233 na\239ve" `inlineShouldBe` [Text "caf\233 na\239ve"]

  , testCase "whitespace between sibling inline elements in para" $ do
      let (ws, bs) = parseBlockFromXML
            (wrap "<para><bold>a</bold> <emphasis>b</emphasis></para>")
      ws @?= []
      case bs of
        [Paragraph inlines] ->
          inlines @?= [Bold [Text "a"], Text " ", Emph [Text "b"]]
        _ -> assertFailure $ "unexpected: " ++ show bs
  ]
