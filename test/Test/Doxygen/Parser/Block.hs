{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.Block (tests) where

import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "paragraph" $
      blockShouldMatch "<para>Hello</para>" $ \b ->
        b @?= Paragraph [Text "Hello"]

  , testCase "empty paragraph produces nothing" $ do
      let (ws, bs) = parseBlockFromXML (wrap "<para></para>")
      ws @?= []
      bs @?= []

  , testCase "whitespace-only paragraph produces nothing" $ do
      let (ws, bs) = parseBlockFromXML (wrap "<para>   </para>")
      ws @?= []
      bs @?= []

  , testCase "para with mixed block and inline content" $ do
      let (_, bs) = parseBlockFromXML $ wrap $ Text.concat
            [ "<para>"
            , "Some text"
            , "<simplesect kind=\"note\"><para>A note</para></simplesect>"
            , "</para>"
            ]
      bs @?= [ Paragraph [Text "Some text"]
             , SimpleSect SSNote [Paragraph [Text "A note"]]
             ]

  , testCase "para with only a parameterlist produces no empty paragraph" $ do
      let (_, bs) = parseBlockFromXML $ wrap $ Text.concat
            [ "<para>"
            , mkParamListXML "param" [(Nothing, "x", "Desc")]
            , "</para>"
            ]
      bs @?= [ParamList ParamListParam
                [Param { paramName = "x"
                       , paramDirection = Nothing
                       , paramDesc = [Paragraph [Text "Desc"]]
                       }]]

  , testCase "parameterlist (param kind)" $
      blockShouldMatch (mkParamListXML "param" [(Just "in", "x", "The input")]) $
        \case
          ParamList ParamListParam [p] -> do
            p.paramName @?= "x"
            p.paramDirection @?= Just DirIn
          b -> assertFailure $ "unexpected: " ++ show b

  , testCase "parameterlist (retval kind)" $
      blockShouldMatch (mkParamListXML "retval" [(Nothing, "0", "Success")]) $
        \case
          ParamList ParamListRetVal _ -> pure ()
          b -> assertFailure $ "expected retval list, got: " ++ show b

  , testCase "simplesect return" $
      blockShouldMatch "<simplesect kind=\"return\"><para>The result</para></simplesect>" $
        \case
          SimpleSect SSReturn _ -> pure ()
          b -> assertFailure $ "expected SSReturn: " ++ show b

  , testCase "programlisting" $
      blockShouldMatch
        ("<programlisting>"
         <> "<codeline><highlight class=\"normal\">int<sp/>x<sp/>=<sp/>0;</highlight></codeline>"
         <> "</programlisting>") $
        \case
          CodeBlock [line] -> line @?= "int x = 0;"
          b -> assertFailure $ "expected code block: " ++ show b

  , testCase "xrefsect (deprecated)" $
      blockShouldMatch
        ("<xrefsect id=\"deprecated\">"
         <> "<xreftitle>Deprecated</xreftitle>"
         <> "<xrefdescription><para>Use new_func instead</para></xrefdescription>"
         <> "</xrefsect>") $
        \case
          XRefSect "Deprecated" _ -> pure ()
          b -> assertFailure $ "expected xrefsect: " ++ show b

  , testCase "table preserves content as Tag without warning" $ do
      let (ws, bs) = parseBlockFromXML (wrap "<table><row><entry><para>cell</para></entry></row></table>")
      assertBool ("no table warning expected, got: " ++ show [w | w <- ws, w.element == "table"])
                 (not $ any (\w -> w.element == "table") ws)
      case bs of
        [Tag tag _children] -> tag @?= "table"
        _ -> assertFailure $ "expected Tag: " ++ show bs

  , testCase "unknown block element emits warning + Tag" $ do
      let (ws, bs) = parseBlockFromXML (wrap "<sect1><title>Heading</title></sect1>")
      case ws of
        (w : _) -> w.context @?= BlockLevel
        _       -> assertFailure $ "expected at least 1 warning, got: " ++ show ws
      case bs of
        [Tag tag _children] -> tag @?= "sect1"
        _ -> assertFailure $ "expected Tag: " ++ show bs
  ]
