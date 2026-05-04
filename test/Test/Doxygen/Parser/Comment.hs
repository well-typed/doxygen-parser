{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.Comment (tests) where

import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "brief and detailed" $ do
      let (ws, mc) = parseCommentFromXML (mkCommentXML "Brief text" "Detailed text")
      ws @?= []
      case mc of
        Just c -> do
          c.brief @?= [Text "Brief text"]
          length c.detailed @?= 1
        Nothing -> assertFailure "expected a comment"

  , testCase "brief only" $ do
      let (_, mc) = parseCommentFromXML (mkCommentXML "Brief only" "")
      case mc of
        Just c -> do
          c.brief @?= [Text "Brief only"]
          c.detailed @?= []
        Nothing -> assertFailure "expected a comment"

  , testCase "detailed only" $ do
      let (_, mc) = parseCommentFromXML (mkCommentXML "" "Detailed only")
      case mc of
        Just c -> do
          c.brief @?= []
          length c.detailed @?= 1
        Nothing -> assertFailure "expected a comment"

  , testCase "empty descriptions produce Nothing" $ do
      let (_, mc) = parseCommentFromXML (mkCommentXML "" "")
      mc @?= Nothing

  , testCase "brief with inline formatting" $ do
      let xml = Text.concat
            [ "<root>"
            , "  <briefdescription>"
            , "    <para>Use <computeroutput>foo</computeroutput> for bar</para>"
            , "  </briefdescription>"
            , "  <detaileddescription></detaileddescription>"
            , "</root>"
            ]
      let (_, mc) = parseCommentFromXML xml
      case mc of
        Just c ->
          assertBool "should have mono inline" $
            any (\case Mono _ -> True; _ -> False) c.brief
        Nothing -> assertFailure "expected a comment"

  , testCase "multiple paragraphs in detailed" $ do
      let (_, mc) = parseCommentFromXML $ Text.concat
            [ "<root>"
            , "  <briefdescription></briefdescription>"
            , "  <detaileddescription>"
            , "    <para>First paragraph</para>"
            , "    <para>Second paragraph</para>"
            , "  </detaileddescription>"
            , "</root>"
            ]
      case mc of
        Just c  -> length c.detailed @?= 2
        Nothing -> assertFailure "expected a comment"
  ]
