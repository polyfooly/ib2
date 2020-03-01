-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module IB2.Node.API
    ( module IB2.Node.API
    , module IB2.Posts.API
    ) where

import Servant

import IB2.FrontendHost.API
import IB2.Posts.API
import IB2.Service.Events.Types


type NodeServiceAPI =
         "eventstoreConfig" :> Get '[JSON] EventStoreConfig

type TranslatedAPI =
         PostsAPI
    :<|> FrontendHostAPI

translatedAPI = Proxy @TranslatedAPI
  
type NodeAPI = NodeServiceAPI :<|> TranslatedAPI

nodeAPI = Proxy @NodeAPI
