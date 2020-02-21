-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.API.Client where

import Control.Monad
import Control.Lens

import Safe

--import Servant.API.ResponseHeaders
import Data.Proxy
import Data.Text (Text)
import Data.Either.Combinators

import qualified Data.ByteString.Char8 as BS

import Servant.API hiding (Post)
import Servant.Reflex
import Servant.Pagination

import Reflex.Dom hiding (Client, HNil, HCons)
    
import IB2.Common.API
import IB2.Common.Types


apiClient :: forall t m. MonadWidget t m 
    => Text -> Client t m PostsCQAPI ()
apiClient v = client 
    (Proxy @PostsCQAPI)
    (Proxy @m) (Proxy @())
    (constDyn baseURL)
    where baseURL = BasePath $ "/api/" <> v <> "/"

postPost' :<|> (
         postById
    :<|> threadById
    :<|> recentThreadsByTag ) = apiClient "v1"

postPost' :: (_) => _
--postById :: (_) => _
--recentThreadsByTag :: (_) => _
--threadById :: (_) => _

recentThreadsPaginated :: (_)
    => Dynamic t PostTag -> Dynamic t Int -> Dynamic t Int 
    -> Dynamic t (Maybe Int)
    -> Event t ()
    -> m (Dynamic t (Maybe Int), Dynamic t [Thread])
recentThreadsPaginated tag' per' page' amount' trigger = do
    let ranges = putRange <$> range
        range = Range Nothing
            <$> per'
            <*> ((*) <$> per' <*> page')
            ?? RangeDesc
            ?? Proxy @"date"

    rec sucRes <- holdDyn Nothing $ reqSuccess <$> response
        response <- recentThreadsByTag
            (Right <$> tag')
            (maybe QNone QParamSome <$> amount')
            (Right <$> ranges)
            trigger

    let threads = maybe [] id <$> fmap resourcePage <$> sucRes
        total = fmap resourceTotalCount <$> sucRes

    pure (total, threads)

getThreadById :: (_)
    => Dynamic t PostID
    -> Event t ()
    -> m (Dynamic t (Maybe Thread))
getThreadById id' trigger = do
    response <- threadById (Right <$> id') trigger
    sucRes <- holdDyn Nothing $ reqSuccess <$> response

    pure $ join <$> sucRes

postPost :: (_)
    => Dynamic t PostData
    -> Event t ()
    -> m (Event t (Maybe PostID))
postPost postData trigger = do
    response <- postPost' (Right <$> postData) trigger
    let sucRes = reqSuccess <$> response

    pure $ join <$> sucRes
