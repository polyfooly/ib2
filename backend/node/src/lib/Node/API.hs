-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Node.API where

import Servant
import FrontendHost.API

type TestAPI1 = 
       "test1" :> Capture "x" String :> Get '[JSON] Integer
  :<|> "test2" :> Get '[JSON] String
testAPI1 :: Proxy TestAPI1
testAPI1 = Proxy

type TestAPI2 = 
       "test3" :> Capture "x" Int :> Get '[JSON] String
  :<|> "test4" :> Get '[JSON] String
  :<|> "test5" :> Post '[JSON] String
testAPI2 :: Proxy TestAPI2
testAPI2 = Proxy

type NodeAPI =
       TestAPI1
  :<|> TestAPI2
  :<|> FrontendHostAPI

nodeAPI :: Proxy NodeAPI
nodeAPI = Proxy
  