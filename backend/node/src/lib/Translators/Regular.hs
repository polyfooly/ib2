-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}

module Translators.Regular where

import Servant
import Servant.Client
import Control.Monad.Trans.Except
import Control.Exception (try)


-- TODO: Refactor Translator.Regular (unnecessary second exception...) 
getIOClient :: HasClient ClientM api => Proxy api -> ClientEnv -> Client IO api
getIOClient api env =
    hoistClient api
        ( fmap (either (error . show) id)
        . flip runClientM env
        )
        (client api)

ioToHandler :: IO a -> Handler a
ioToHandler a = Handler (ExceptT (try a))

regularTranslator :: HasClient ClientM api => Proxy api -> ClientEnv -> Client Handler api
regularTranslator api env = 
    hoistClient api ioToHandler (getIOClient api env)