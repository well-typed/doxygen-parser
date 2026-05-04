{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.Param (tests) where

import Data.Text (Text)
import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ mkParamTest "param with direction=in"    (Just "in")    "x"      (Just DirIn)
  , mkParamTest "param with direction=out"   (Just "out")   "result" (Just DirOut)
  , mkParamTest "param with direction=inout" (Just "inout") "buf"    (Just DirInOut)
  , mkParamTest "param with no direction"    Nothing        "x"      Nothing

  , testCase "param with empty description" $
      blockShouldMatch (mkParamListXML "param" [(Nothing, "x", "")]) $
        \case
          -- Empty <para> in description is dropped, so paramDesc is empty
          -- (the mkParamListXML wraps desc in <para>, but empty text
          -- produces an empty paragraph which is dropped)
          ParamList _ [_p] -> pure ()
          b -> assertFailure $ "unexpected: " ++ show b

  , testCase "param with missing name is skipped" $ do
      let xml = wrap $ Text.concat
            [ "<parameterlist kind=\"param\">"
            , "<parameteritem>"
            , "  <parameternamelist></parameternamelist>"
            , "  <parameterdescription><para>Desc</para></parameterdescription>"
            , "</parameteritem>"
            , "</parameterlist>"
            ]
      let (_, bs) = parseBlockFromXML xml
      case bs of
        [ParamList _ params] ->
          length params @?= 0
        _ -> assertFailure $ "unexpected: " ++ show bs

  , testCase "multiple params" $
      blockShouldMatch
        (mkParamListXML "param"
          [ (Nothing, "a", "First")
          , (Nothing, "b", "Second")
          ]) $
        \case
          ParamList _ params -> length params @?= 2
          b -> assertFailure $ "unexpected: " ++ show b
  ]
  where
    mkParamTest :: String -> Maybe Text -> Text -> Maybe ParamDirection -> TestTree
    mkParamTest name mDir paramName expectedDir =
      testCase name $
        blockShouldMatch (mkParamListXML "param" [(mDir, paramName, "Desc")]) $
          \case
            ParamList _ [p] -> p.paramDirection @?= expectedDir
            b -> assertFailure $ "unexpected: " ++ show b
