module Test.Doxygen.Parser.XMLFileResult (tests) where

import Data.Map.Strict qualified as Map
import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "struct compound extracts struct doc and field docs" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "struct" "structfoo" "foo_t" "A foo struct" $
            mkSection "public-attrib" $ Text.concat
                [ mkMember "variable" "field_x" "x" "X coordinate" ""
                , mkMember "variable" "field_y" "y" "Y coordinate" ""
                ]) $ \result -> do
          assertBool "should have struct doc" $
            Map.member (KeyStruct "foo_t") result.comments
          assertBool "should have field x" $
            Map.member (KeyField "foo_t" "x") result.comments
          assertBool "should have field y" $
            Map.member (KeyField "foo_t" "y") result.comments

  , testCase "group compound extracts title and member docs" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "group" "group__core" "core" "" $
            "<title>Core Functions</title>"
            <> mkSection "func"
                 (mkMember "function" "func_init" "init" "Initialize" "")
        ) $ \result -> do
          result.groupTitles @?= [("core", "Core Functions")]
          assertBool "should have init decl" $
            Map.member (KeyDecl "init") result.comments

  , testCase "enum member extracts enum value docs" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "file" "myfile_8h" "myfile.h" "" $
            mkSection "enum" $
              mkMember "enum" "enum_color" "color_t" "A color enum" $ Text.concat
                [ mkEnumVal "ev_red"  "RED"  "Red color"  ""
                , mkEnumVal "ev_blue" "BLUE" "Blue color" ""
                ]
        ) $ \result -> do
          assertBool "should have color_t decl" $
            Map.member (KeyDecl "color_t") result.comments
          assertBool "should have RED" $
            Map.member (KeyEnumValue "color_t" "RED") result.comments
          assertBool "should have BLUE" $
            Map.member (KeyEnumValue "color_t" "BLUE") result.comments

  , testCase "known-but-ignored compounddef children produce no warnings" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "struct" "structbar" "bar_t" "A bar struct" $
            "<location file=\"test.h\" line=\"1\"/>"
            <> "<includes refid=\"test_8h\">test.h</includes>"
        ) $ \result -> do
          assertBool "should have struct doc" $
            Map.member (KeyStruct "bar_t") result.comments
          result.warnings @?= []

  , testCase "truly unknown compounddef children emit warnings" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "struct" "structbar" "bar_t" "A bar struct"
            "<nonstandard>unexpected content</nonstandard>"
        ) $ \result -> do
          assertBool "should have struct doc" $
            Map.member (KeyStruct "bar_t") result.comments
          shouldWarnAbout result.warnings "compounddef" "nonstandard"
          case result.warnings of
            [w] -> w.degradation @?= Omitted
            _   -> assertFailure $ "expected 1 warning, got: " ++ show result.warnings

  , testCase "unknown memberdef children emit warnings" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "group" "group__test" "test" "" $
            mkSection "func" $
              mkMember "function" "test_1" "foo" "A function"
                "<type>void</type><bogus_tag>unexpected</bogus_tag>"
        ) $ \result -> do
          assertBool "should have decl doc" $
            Map.member (KeyDecl "foo") result.comments
          shouldWarnAbout result.warnings "memberdef" "bogus_tag"

  , testCase "unknown sectiondef children emit warnings" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "group" "group__test" "test" "" $
            mkSection "func" $
              mkMember "function" "test_1" "bar" "A function" ""
              <> "<unexpected_child/>"
        ) $ \result ->
          shouldWarnAbout result.warnings "sectiondef" "unexpected_child"

  , testCase "unknown enumvalue children emit warnings" $
      withExtractedEntity
        (mkDoxygen $ mkCompound "group" "group__test" "test" "" $
            mkSection "enum" $
              mkMember "enum" "test_1" "color_t" "Colors" $
                mkEnumVal "ev1" "RED" "Red"
                  "<initializer>= 0</initializer><alien_element/>"
        ) $ \result -> do
          assertBool "should have enum value doc" $
            Map.member (KeyEnumValue "color_t" "RED") result.comments
          shouldWarnAbout result.warnings "enumvalue" "alien_element"

  , testCase "compounddef with no compoundname produces empty result" $
      withExtractedEntity (Text.concat
        [ "<doxygen>"
        , "<compounddef kind=\"struct\" id=\"structempty\">"
        , "  <briefdescription><para>Orphaned doc</para></briefdescription>"
        , "  <detaileddescription></detaileddescription>"
        , "</compounddef>"
        , "</doxygen>"
        ]) $ \result ->
          result.comments @?= Map.empty
  ]
