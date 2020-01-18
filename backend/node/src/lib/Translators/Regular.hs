-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Translators.Regular where

import qualified Data.Text as T

import Control.Monad.Trans.Except
import Control.Exception (try)

import GHC.TypeLits

import Servant
import Servant.Pagination
import Servant.Client

-- TODO: Refactor Translator.Regular (unnecessary second exception...) 

ioToHandler :: IO a -> Handler a
ioToHandler a = Handler (ExceptT (try a))

translateSingle :: ClientEnv -> ClientM api -> Handler api
translateSingle env c =
    ( ioToHandler
    . fmap (either (error . show) id)
    . flip runClientM env) c

regularTranslator :: HasClient ClientM api
    => Proxy api
    -> ClientEnv
    -> Client Handler api
regularTranslator api env = 
    hoistClient api (translateSingle env) (client api)


-- some hacks for pagination requests translation support
instance ( FromHttpApiData (RangeType res field)
         , ToHttpApiData (RangeType res field)
         , KnownSymbol field 
         ) => FromHttpApiData (ContentRange '[field] res) where
    parseUrlPiece txt =
        -- Valid only in context of this program, when type is already known,
        -- verification isn't required
        let [_, range] = T.words txt
            [start, end] = T.splitOn ".." range
        in ContentRange
            <$> (parseUrlPiece start) 
            <*> (parseUrlPiece end)
            <*> pure (Proxy @field)

instance KnownSymbol field => FromHttpApiData (AcceptRanges '[field]) where
    -- same ^
    parseUrlPiece txt = pure $ AcceptRanges @'[field]
