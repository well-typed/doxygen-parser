module Test.Doxygen.Parser.Properties (tests) where

import Data.Text qualified as Text
import Test.QuickCheck ((===))
import Test.QuickCheck qualified as QC
import Test.Tasty
import Test.Tasty.QuickCheck (testProperty)

import Doxygen.Parser.Internal (normalizeWhitespace)

tests :: [TestTree]
tests =
  [ testProperty "normalizeWhitespace is idempotent" $ \(QC.PrintableString s) ->
      let t = Text.pack s
      in  normalizeWhitespace (normalizeWhitespace t) === normalizeWhitespace t

  , testProperty "normalizeWhitespace: no internal double spaces" $
      \(QC.PrintableString s) ->
        let t = Text.pack s
            result = normalizeWhitespace t
            -- Strip the (at most one) leading and trailing space
            interior = Text.dropWhileEnd (== ' ') $ Text.dropWhile (== ' ') result
        in  not (Text.isInfixOf "  " interior)
  ]
