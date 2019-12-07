-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module Translators.Regular where

import Servant
import Servant.Server
import Servant.Client
import Control.Monad.Trans.Except
import Control.Exception (try)

-- TODO: Refactor Translator.Regular (unnecessary second exception...) 

ioToHandler :: IO a -> Handler a
ioToHandler a = Handler (ExceptT (try a))

translateSingle :: ClientEnv -> ClientM api -> Handler api
translateSingle env c =
    ( ioToHandler
    . fmap (either (error . show) id)
    . flip runClientM env) c

regularTranslator :: HasClient ClientM api =>
    Proxy api ->
    ClientEnv ->
    Client Handler api

regularTranslator api env = 
    hoistClient api (translateSingle env) (client api)
