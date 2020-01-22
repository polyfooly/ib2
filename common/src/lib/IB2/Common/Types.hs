-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ViewPatterns #-}

module IB2.Common.Types
    ( module IB2.Common.Types 
    , module Posts.Types
    ) where

import qualified Data.Text as T

import GHC.TypeLits

import Servant
import Servant.Pagination
 
import Posts.Types


-- support for automatic client function derivation
-- for paginated queries
instance ( FromHttpApiData (RangeType res field)
         , ToHttpApiData (RangeType res field)
         , KnownSymbol field 
         ) => FromHttpApiData (ContentRange '[field] res) where
    -- maybe incorrect? I dunno how it should really work
    parseUrlPiece (T.words -> [_, (T.splitOn ".." -> [start, end]) ]) =
        ContentRange
            <$> (parseUrlPiece start) 
            <*> (parseUrlPiece end)
            <*> pure (Proxy @field)

    parseUrlPiece _ = Left "Invalid Range"

instance (KnownSymbol field) => FromHttpApiData (AcceptRanges '[field]) where
    -- same ^
    parseUrlPiece _ = pure $ AcceptRanges @'[field]
