{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.CodeBlock (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "single code line" $
      blockShouldMatch
        ("<programlisting>"
         <> "<codeline><highlight class=\"normal\">return<sp/>0;</highlight></codeline>"
         <> "</programlisting>") $
        \case
          CodeBlock [line] -> line @?= "return 0;"
          b -> assertFailure $ "expected code block: " ++ show b

  , testCase "multiple code lines" $
      blockShouldMatch
        ("<programlisting>"
         <> "<codeline><highlight class=\"normal\">int<sp/>x;</highlight></codeline>"
         <> "<codeline><highlight class=\"normal\">x<sp/>=<sp/>0;</highlight></codeline>"
         <> "</programlisting>") $
        \case
          CodeBlock codeLines -> length codeLines @?= 2
          b -> assertFailure $ "expected 2 code lines: " ++ show b

  , testCase "code line with ref" $
      blockShouldMatch
        ("<programlisting>"
         <> "<codeline><highlight class=\"normal\">"
         <> "<ref refid=\"abc\">my_type</ref><sp/>x;</highlight></codeline>"
         <> "</programlisting>") $
        \case
          CodeBlock [line] -> line @?= "my_type x;"
          b -> assertFailure $ "expected code block: " ++ show b

  , testCase "empty code block" $
      blockShouldMatch "<programlisting></programlisting>" $
        \case
          CodeBlock [] -> pure ()
          b -> assertFailure $ "expected empty code block: " ++ show b
  ]
