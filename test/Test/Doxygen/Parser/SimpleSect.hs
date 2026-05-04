{-# LANGUAGE LambdaCase #-}

module Test.Doxygen.Parser.SimpleSect (tests) where

import Data.Text (Text)
import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser
import Test.Doxygen.Parser.Helpers

tests :: [TestTree]
tests =
  [ mkSimpleSectTest "return"     SSReturn
  , mkSimpleSectTest "warning"    SSWarning
  , mkSimpleSectTest "note"       SSNote
  , mkSimpleSectTest "see"        SSSee
  , mkSimpleSectTest "since"      SSSince
  , mkSimpleSectTest "version"    SSVersion
  , mkSimpleSectTest "pre"        SSPre
  , mkSimpleSectTest "post"       SSPost
  , mkSimpleSectTest "deprecated" SSDeprecated
  , mkSimpleSectTest "remark"     SSRemark
  , mkSimpleSectTest "attention"  SSAttention
  , mkSimpleSectTest "todo"       SSTodo
  , mkSimpleSectTest "invariant"  SSInvariant
  , mkSimpleSectTest "author"     SSAuthor
  , mkSimpleSectTest "date"       SSDate

  , testCase "par with title" $
      blockShouldMatch
        ("<simplesect kind=\"par\">"
         <> "<title>My Title</title>"
         <> "<para>Content</para>"
         <> "</simplesect>") $
        \case
          SimpleSect (SSPar title) _ -> title @?= "My Title"
          b -> assertFailure $ "expected SSPar: " ++ show b

  , testCase "unknown kind defaults to SSNote with warning" $ do
      let (ws, bs) = parseBlockFromXML
            (wrap "<simplesect kind=\"bogus\"><para>X</para></simplesect>")
      case ws of
        [w] -> do
          w.context @?= UnknownSectKind
          w.degradation @?= DefaultedTo "Note"
        _ -> assertFailure $ "expected 1 warning, got: " ++ show ws
      case bs of
        [SimpleSect SSNote _] -> pure ()
        _ -> assertFailure $ "expected SSNote: " ++ show bs

  , testCase "missing kind defaults to SSNote with warning" $ do
      let (ws, bs) = parseBlockFromXML
            (wrap "<simplesect><para>X</para></simplesect>")
      case ws of
        [w] -> w.context @?= UnknownSectKind
        _   -> assertFailure $ "expected 1 warning, got: " ++ show ws
      case bs of
        [SimpleSect SSNote _] -> pure ()
        _ -> assertFailure $ "expected SSNote: " ++ show bs
  ]

mkSimpleSectTest :: Text -> SimpleSectKind -> TestTree
mkSimpleSectTest kindAttr expected =
  testCase (Text.unpack kindAttr) $
    blockShouldMatch
      ("<simplesect kind=\"" <> kindAttr <> "\"><para>Content</para></simplesect>") $
      \case
        SimpleSect k _ -> k @?= expected
        b -> assertFailure $ "expected simplesect: " ++ show b
