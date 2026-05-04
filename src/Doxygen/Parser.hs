-- | Public API for parsing Doxygen XML output into a typed Haskell AST.
--
-- = Overview
--
-- 'parse' invokes the @doxygen@ binary on a non-empty list of C\/C++
-- header files, walks the resulting @xml\/@ directory, and assembles a
-- 'Doxygen' value that maps each documented entity to a structured
-- 'Comment' tree.  The @doxygen@ binary must be available on @PATH@ (or
-- configured via 'Config').
--
-- = Quick start
--
-- @
-- import "Doxygen.Parser"
-- import Data.List.NonEmpty (NonEmpty (..))
--
-- main :: IO ()
-- main = do
--     'Result'{doxygen, warnings, doxygenVersion} \<-
--         'parse' 'defaultConfig' (\"myheader.h\" :| [])
--     mapM_ print warnings
--     print ('lookupComment' ('DoxygenKey' \"myFunc\") doxygen)
-- @
--
-- 'parse' throws 'DoxygenException' if the @doxygen@ invocation itself
-- fails; recoverable problems (unknown XML elements, malformed refs,
-- etc.) are returned as 'Warning's in the 'Result'.
--
-- = Stability
--
-- This module, "Doxygen.Parser.Types", and "Doxygen.Parser.Warning"
-- form the supported public API.
--
module Doxygen.Parser (
    -- * Configuration
    Config(..)
  , defaultConfig
    -- * Parsing
  , parse
  , Result(..)
    -- * State type
  , Doxygen -- Opaque
  , emptyDoxygen
    -- * Lookup keys
  , DoxygenKey(..)
  , lookupComment
    -- * Group sections
  , lookupGroupMembership
  , lookupGroupInfo
    -- * Errors
  , DoxygenException(..)
    -- * Comment types (from "Doxygen.Parser.Types")
  , Comment(..)
  , Block(..)
  , Inline(..)
  , Param(..)
  , DoxyRef(..)
  , RefKind(..)
  , ParamListKind(..)
  , ParamDirection(..)
  , SimpleSectKind(..)
    -- * Warnings (from "Doxygen.Parser.Warning")
  , Warning(..)
  , Context(..)
  , Degradation(..)
  ) where

import Doxygen.Parser.Internal
import Doxygen.Parser.Types
import Doxygen.Parser.Warning
