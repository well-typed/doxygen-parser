-- | Tests for Doxyfile generation ('generateConfig').
module Test.Doxygen.Parser.Config (tests) where

import Data.List.NonEmpty (NonEmpty ((:|)))
import Data.Text (Text)
import Data.Text qualified as Text
import Test.Tasty
import Test.Tasty.HUnit

import Doxygen.Parser.Internal (Config (..), defaultConfig, generateConfig)

tests :: [TestTree]
tests =
  [ testCase "no aliases emits no ALIASES line" $
      aliasLines defaultConfig @?= []
  , testCase "each alias appends one quoted key=value pair" $ do
      let config =
            defaultConfig
              { aliases =
                  [ ("threadsafety", "\\par Thread safety:^^")
                  , ("sdlversion", "3.2.0")
                  ]
              }
      aliasLines config
        @?= [ "ALIASES += threadsafety=\"\\par Thread safety:^^\""
            , "ALIASES += sdlversion=\"3.2.0\""
            ]
  ]

-- | The @ALIASES@ lines of the generated Doxyfile.
aliasLines :: Config -> [Text]
aliasLines config =
  filter ("ALIASES" `Text.isPrefixOf`) $
    Text.lines (generateConfig config ("sdl.h" :| []) "/out")
