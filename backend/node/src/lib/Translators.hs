-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0]

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module Translators 
    ( translators
    ) where

import Servant
import Servant.Client
import Network.HTTP.Client (Manager)

import Node.Types
import Node.API

import Translators.Raw (rawTranslator)
import Translators.Regular (regularTranslator)


postsTranslator = regularTranslator postsAPI
frontendHostTranslator = rawTranslator


-- TODO: routing
localUrl :: Int -> BaseUrl
localUrl port = BaseUrl Http "127.0.0.1" port ""

localEnv :: Manager -> Int -> ClientEnv
localEnv manager' port = mkClientEnv manager' (localUrl port)

translators :: NodeConfig -> Manager -> Server TranslatedAPI
translators config manager' = 
         (postsTranslator $ localEnv manager' $ postsPort config)
    :<|> (frontendHostTranslator (frontendHostPort config) manager')
