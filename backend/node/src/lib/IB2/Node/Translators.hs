-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0]

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module IB2.Node.Translators 
    ( translators
    ) where

import Servant
import Servant.Client
import Network.HTTP.Client (Manager)

import IB2.Node.Types
import IB2.Node.API

import IB2.Node.Translators.Raw (rawTranslator)
import IB2.Node.Translators.Regular (regularTranslator)


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
