{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.List (tests) where

import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "itemized list" $
      blockShouldMatch
        ("<itemizedlist>"
         <> "<listitem><para>First</para></listitem>"
         <> "<listitem><para>Second</para></listitem>"
         <> "</itemizedlist>") $
        \case
          ItemizedList items -> length items @?= 2
          b -> assertFailure $ "expected itemized list: " ++ show b

  , testCase "ordered list" $
      blockShouldMatch
        ("<orderedlist>"
         <> "<listitem><para>First</para></listitem>"
         <> "<listitem><para>Second</para></listitem>"
         <> "<listitem><para>Third</para></listitem>"
         <> "</orderedlist>") $
        \case
          OrderedList items -> length items @?= 3
          b -> assertFailure $ "expected ordered list: " ++ show b

  , testCase "nested lists" $
      blockShouldMatch
        ("<itemizedlist>"
         <> "<listitem>"
         <> "  <para>Outer</para>"
         <> "  <itemizedlist>"
         <> "    <listitem><para>Inner</para></listitem>"
         <> "  </itemizedlist>"
         <> "</listitem>"
         <> "</itemizedlist>") $
        \case
          ItemizedList [item] ->
            assertBool "should have nested list" $
              any (\case ItemizedList _ -> True; _ -> False) item
          b -> assertFailure $ "expected nested list: " ++ show b

  , testCase "list item with formatted content" $
      blockShouldMatch
        ("<itemizedlist>"
         <> "<listitem><para>Use <bold>this</bold> function</para></listitem>"
         <> "</itemizedlist>") $
        \case
          ItemizedList [[Paragraph is]] ->
            assertBool "should have bold" $
              any (\case Bold _ -> True; _ -> False) is
          b -> assertFailure $ "unexpected: " ++ show b
  ]
