-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module IB2.Frontend.Router where

import Control.Lens

import           Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as BS
import qualified URI.ByteString as U

import           Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T

import Reflex.Dom
import Reflex.Dom.Contrib.Router

-- slightly edited partialPathRoute
-- (https://github.com/reflex-frp/reflex-dom-contrib/blob/master/src/Reflex/Dom/Contrib/Router.hs)
routeApp :: (_)
    => Event t Text
    -> m (Dynamic t [Text])
routeApp pathUpdates = do
    route' updateUrl parseParts pathUpdates
    where
        
        toPath :: Text -> ByteString
        toPath dynpath = T.encodeUtf8 $ "/" <> cleanT dynpath

        updateUrl :: URI -> Text -> URI
        updateUrl u updateParts = u & U.pathL .~ toPath updateParts

        parseParts :: URI -> [Text]
        parseParts u = T.splitOn "/" $ T.decodeUtf8 $ cleanB (u ^. U.pathL)

        cleanT = T.dropWhile (=='/')
        cleanB = BS.dropWhile (== '/')
