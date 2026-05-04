module Test.Doxygen.Parser.StructuralWarnings (tests) where

import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ testCase "unknown briefdescription child warns" $ do
      let xml = Text.concat
            [ "<root>"
            , "  <briefdescription>"
            , "    <para>Normal para</para>"
            , "    <bogus>unexpected</bogus>"
            , "  </briefdescription>"
            , "  <detaileddescription></detaileddescription>"
            , "</root>"
            ]
          (ws, mc) = parseCommentFromXML xml
      assertBool "should still produce a comment" $ mc /= Nothing
      shouldWarnAbout ws "briefdescription" "bogus"

  , testCase "unknown parameteritem child warns" $ do
      let (ws, _) = parseBlockFromXML $ wrap $ Text.concat
            [ "<parameterlist kind=\"param\">"
            , "  <parameteritem>"
            , "    <parameternamelist>"
            , "      <parametername direction=\"in\">x</parametername>"
            , "    </parameternamelist>"
            , "    <parameterdescription><para>The input.</para></parameterdescription>"
            , "    <alien/>"
            , "  </parameteritem>"
            , "</parameterlist>"
            ]
      shouldWarnAbout ws "parameteritem" "alien"

  , testCase "unknown programlisting child warns" $ do
      let (ws, bs) = parseBlockFromXML $ wrap $ Text.concat
            [ "<programlisting>"
            , "  <codeline><highlight class=\"normal\">code</highlight></codeline>"
            , "  <bogus/>"
            , "</programlisting>"
            ]
      shouldWarnAbout ws "programlisting" "bogus"
      case bs of
        [CodeBlock lines'] -> length lines' @?= 1
        _ -> assertFailure $ "expected CodeBlock: " ++ show bs

  , testCase "unknown codeline child warns" $ do
      let (ws, _) = parseBlockFromXML $ wrap $ Text.concat
            [ "<programlisting>"
            , "  <codeline>"
            , "    <highlight class=\"normal\">code</highlight>"
            , "    <mystery/>"
            , "  </codeline>"
            , "</programlisting>"
            ]
      shouldWarnAbout ws "codeline" "mystery"
  ]
