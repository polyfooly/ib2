-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0]

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Translators (
    translators
) where

import Servant
import Servant.Client
import Network.HTTP.Client (Manager)

import Node.Config
import Node.API

import Translators.Raw (rawTranslator)
import Translators.Regular (regularTranslator)



testTranslator1 = regularTranslator testAPI1 --regularTranslator testAPI
testTranslator2 = regularTranslator testAPI2
frontendHostTranslator = rawTranslator

localUrl :: Int -> BaseUrl
localUrl port = (BaseUrl Http "127.0.0.1" port "")

translators :: NodeConfig -> Manager -> Server NodeAPI
translators config manager' = 
         testTranslator1 (mkClientEnv manager' (localUrl 5476))
    :<|> testTranslator2 (mkClientEnv manager' (localUrl 5477))
    :<|> frontendHostTranslator (frontendHostPort config) manager'