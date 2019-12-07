-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Node.API
    ( module Node.API
    , module Posts.API
    ) where

import Servant

import FrontendHost.API
import Posts.API
import IB2.Service.Events.Types


type NodeServiceAPI =
         "eventstoreConfig" :> Get '[JSON] EventStoreConfig

type TranslatedAPI =
         PostsAPI
    :<|> FrontendHostAPI

translatedAPI :: Proxy TranslatedAPI
translatedAPI = Proxy
  
type NodeAPI = NodeServiceAPI :<|> TranslatedAPI

nodeAPI :: Proxy NodeAPI
nodeAPI = Proxy
