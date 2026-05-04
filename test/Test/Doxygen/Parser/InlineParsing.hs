module Test.Doxygen.Parser.InlineParsing (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "plain text" $
      "hello" `inlineShouldBe` [Text "hello"]
  , testCase "bold" $
      "<bold>text</bold>" `inlineShouldBe` [Bold [Text "text"]]
  , testCase "emphasis" $
      "<emphasis>text</emphasis>" `inlineShouldBe` [Emph [Text "text"]]
  , testCase "computeroutput" $
      "<computeroutput>code</computeroutput>" `inlineShouldBe` [Mono [Text "code"]]
  , testCase "ref without kindref" $
      "<ref refid=\"abc\">my_func</ref>" `inlineShouldBe` [Ref (DoxyRef "my_func" Nothing) "my_func"]
  , testCase "ref with kindref compound" $
      "<ref refid=\"structfoo\" kindref=\"compound\">foo</ref>"
        `inlineShouldBe` [Ref (DoxyRef "foo" (Just RefCompound)) "foo"]
  , testCase "ref with kindref member" $
      "<ref refid=\"file_1abc\" kindref=\"member\">bar</ref>"
        `inlineShouldBe` [Ref (DoxyRef "bar" (Just RefMember)) "bar"]
  , testCase "anchor" $
      "<anchor id=\"foo\"/>" `inlineShouldBe` [Anchor "foo"]
  , testCase "ulink" $
      "<ulink url=\"http://example.com\">click</ulink>"
        `inlineShouldBe` [Link [Text "click"] "http://example.com"]
  , testCase "linebreak" $
      "<linebreak/>" `inlineShouldBe` [Text "\n"]
  , testCase "sp" $
      "<sp/>" `inlineShouldBe` [Text " "]
  , testCase "empty bold" $
      "<bold></bold>" `inlineShouldBe` [Bold []]
  , testCase "empty emphasis" $
      "<emphasis></emphasis>" `inlineShouldBe` [Emph []]

  , testCase "special XML characters" $
      "a &lt; b &amp; c &gt; d" `inlineShouldBe` [Text "a < b & c > d"]

  , testCase "unknown inline degrades to text" $ do
      let (ws, is) = parseInlinesFromXML (wrap "<subscript>x</subscript>")
      case ws of
        [w] -> do
          w.context @?= InlineLevel
          w.degradation @?= DegradedToText
        _ -> assertFailure $ "expected 1 warning, got: " ++ show ws
      is @?= [Text "x"]

  , testCase "unknown inline with empty text" $ do
      let (ws, is) = parseInlinesFromXML (wrap "<subscript/>")
      length ws @?= 1
      is @?= []
  ]
