{-# LANGUAGE LambdaCase #-}

-- | Shared XML-builder and assertion helpers for the test suite.
module Test.Doxygen.Parser.Helpers (
    -- * XML parsing
    mkCursor
  , parseBlockFromXML
  , parseCommentFromXML
  , parseInlinesFromXML
  , wrap
    -- * Assertion combinators
  , inlineShouldBe
  , blockShouldMatch
  , shouldWarnAbout
    -- * XML builders for parameterlist
  , mkParamListXML
  , mkCommentXML
    -- * XML builders for entity extraction
  , mkDoxygen
  , mkCompound
  , mkSection
  , mkMember
  , mkEnumVal
  , withExtractedEntity
    -- * Re-exports for tests that consume entity-extraction results
  , XMLFileResult (..)
  ) where

import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Lazy qualified as LText
import Test.Tasty.HUnit
import Text.XML qualified as XML
import Text.XML.Cursor (Cursor)
import Text.XML.Cursor qualified as Cursor

import Doxygen.Parser
import Doxygen.Parser.Internal (ChildAction (..), XMLFileResult (..),
                                extractBriefAndDetail, extractEntity,
                                forChildren, parseBlockElement,
                                parseInlineChildren)

{-------------------------------------------------------------------------------
  Test helpers: XML parsing
-------------------------------------------------------------------------------}

-- | Parse a raw XML string into a cursor pointing at the root element
mkCursor :: Text -> Cursor
mkCursor xml =
    Cursor.fromDocument $ XML.parseText_ XML.def (LText.fromStrict xml)

-- | Parse all children of @\<root\>@ as block elements
parseBlockFromXML :: Text -> ([Warning], [Block DoxyRef])
parseBlockFromXML xml =
    let root = mkCursor xml
        pairs = map parseBlockElement (Cursor.child root)
    in  (concatMap fst pairs, concatMap snd pairs)

-- | Parse comment from an XML element with brief/detailed descriptions
parseCommentFromXML :: Text -> ([Warning], Maybe (Comment DoxyRef))
parseCommentFromXML xml =
  let cursor = mkCursor xml
      (_warns, parts) = forChildren "root" (Cursor.child cursor) $ \n c ->
        case n of
          "briefdescription"    -> Just (Yield (Left c))
          "detaileddescription" -> Just (Yield (Right c))
          _                     -> Just Skip
      briefDescs = [c | Left c <- parts]
      detailDescs = [c | Right c <- parts]
  in  extractBriefAndDetail briefDescs detailDescs

-- | Parse inline children of the root element
parseInlinesFromXML :: Text -> ([Warning], [Inline DoxyRef])
parseInlinesFromXML xml = parseInlineChildren (mkCursor xml)

-- | Wrap content in a root element
wrap :: Text -> Text
wrap content = "<root>" <> content <> "</root>"

{-------------------------------------------------------------------------------
  Test helpers: assertion combinators
-------------------------------------------------------------------------------}

-- | Assert that parsing an inline XML fragment produces the expected inlines
-- with no warnings.
inlineShouldBe :: Text -> [Inline DoxyRef] -> Assertion
inlineShouldBe xml expected = do
    let (ws, is) = parseInlinesFromXML (wrap xml)
    ws @?= []
    is @?= expected

-- | Assert that parsing a block XML fragment produces a single block matching
-- the predicate, with no warnings.
blockShouldMatch :: Text -> (Block DoxyRef -> Assertion) -> Assertion
blockShouldMatch xml check = do
    let (ws, bs) = parseBlockFromXML (wrap xml)
    ws @?= []
    case bs of
      [b] -> check b
      _   -> assertFailure $ "expected exactly 1 block, got: " ++ show bs

-- | Assert that warnings contain exactly one warning with the given structural
-- context and element name.
shouldWarnAbout :: [Warning] -> Text -> Text -> Assertion
shouldWarnAbout ws parentCtx elemName = do
    let filtered = filter (\w -> w.context == StructureLevel parentCtx) ws
    case filtered of
      [w] -> w.element @?= elemName
      _   -> assertFailure $
               "expected 1 " ++ Text.unpack parentCtx
               ++ " warning about " ++ Text.unpack elemName
               ++ ", got: " ++ show filtered

{-------------------------------------------------------------------------------
  Test helpers: XML builders for parameterlist
-------------------------------------------------------------------------------}

-- | Build a @\<parameterlist\>@ XML fragment.
mkParamListXML :: Text -> [(Maybe Text, Text, Text)] -> Text
mkParamListXML kind params = Text.concat $
    ["<parameterlist kind=\"", kind, "\">"]
    ++ concatMap mkItem params
    ++ ["</parameterlist>"]
  where
    mkItem (mDir, name, desc) =
      [ Text.concat
          [ "<parameteritem>"
          , "  <parameternamelist>"
          , "    <parametername", dirAttr mDir, ">", name, "</parametername>"
          , "  </parameternamelist>"
          , "  <parameterdescription><para>", desc, "</para></parameterdescription>"
          , "</parameteritem>"
          ]
      ]

    dirAttr Nothing    = ""
    dirAttr (Just dir) = " direction=\"" <> dir <> "\""

-- | Build a comment XML element with brief and detailed descriptions.
mkCommentXML :: Text -> Text -> Text
mkCommentXML brief detailed = Text.concat
    [ "<root>"
    , "  <briefdescription>", wrapPara brief, "</briefdescription>"
    , "  <detaileddescription>", wrapPara detailed, "</detaileddescription>"
    , "</root>"
    ]

{-------------------------------------------------------------------------------
  Test helpers: XML builders for entity extraction
-------------------------------------------------------------------------------}

-- | Wrap compound definitions in a @\<doxygen\>@ root.
mkDoxygen :: Text -> Text
mkDoxygen body = "<doxygen>" <> body <> "</doxygen>"

-- | Build a @\<compounddef\>@ with brief description and body content.
mkCompound :: Text -> Text -> Text -> Text -> Text -> Text
mkCompound kind cid name brief body = Text.concat
    [ "<compounddef kind=\"", kind, "\" id=\"", cid, "\">"
    , "<compoundname>", name, "</compoundname>"
    , "<briefdescription>", wrapPara brief, "</briefdescription>"
    , "<detaileddescription></detaileddescription>"
    , body
    , "</compounddef>"
    ]

-- | Build a @\<sectiondef\>@.
mkSection :: Text -> Text -> Text
mkSection kind body = Text.concat
    [ "<sectiondef kind=\"", kind, "\">"
    , body
    , "</sectiondef>"
    ]

-- | Build a @\<memberdef\>@ with brief description and optional body content.
mkMember :: Text -> Text -> Text -> Text -> Text -> Text
mkMember kind mid name brief body = Text.concat
    [ "<memberdef kind=\"", kind, "\" id=\"", mid, "\">"
    , "<name>", name, "</name>"
    , "<briefdescription>", wrapPara brief, "</briefdescription>"
    , "<detaileddescription></detaileddescription>"
    , body
    , "</memberdef>"
    ]

-- | Wrap text in a @\<para\>@; empty input produces empty output (so an empty
-- @\<para\>\</para\>@ is dropped by the parser, matching the real-world
-- shape of @doxygen@ XML).
wrapPara :: Text -> Text
wrapPara "" = ""
wrapPara t  = "<para>" <> t <> "</para>"

-- | Build an @\<enumvalue\>@.
mkEnumVal :: Text -> Text -> Text -> Text -> Text
mkEnumVal evid name brief body = Text.concat
    [ "<enumvalue id=\"", evid, "\">"
    , "<name>", name, "</name>"
    , "<briefdescription><para>", brief, "</para></briefdescription>"
    , "<detaileddescription></detaileddescription>"
    , body
    , "</enumvalue>"
    ]

-- | Parse a @\<compounddef\>@ from XML and run assertions on the result.
withExtractedEntity :: Text -> (XMLFileResult -> Assertion) -> Assertion
withExtractedEntity xml check = do
    let doc = XML.parseText_ XML.def (LText.fromStrict xml)
        root = Cursor.fromDocument doc
    let (_warns, cds) = forChildren "doxygen" (Cursor.child root) $ \n c ->
          case n of
            "compounddef" -> Just (Yield c)
            _             -> Just Skip
    case cds of
      []     -> assertFailure "no compounddef found"
      (cd:_) -> check (extractEntity cd)
