-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE FlexibleContexts #-}

module IB2.Node.Translators.Regular where

import Servant
import Servant.Client

import IB2.Common.Types ()
import IB2.Service.Server


translateSingle :: ClientEnv -> ClientM api -> Handler api
translateSingle env =
      ioToHandler
    . fmap (either (error . show) id)
    . flip runClientM env

regularTranslator :: HasClient ClientM api
    => Proxy api
    -> ClientEnv
    -> Client Handler api
regularTranslator api env = 
    hoistClient api (translateSingle env) (client api)
