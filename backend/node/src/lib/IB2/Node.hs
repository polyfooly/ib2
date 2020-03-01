-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module IB2.Node where

import Servant
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Client (Manager, newManager, defaultManagerSettings)

import IB2.Node.Translators (translators)

import IB2.Node.API
import IB2.Node.Types
import IB2.Node.Service


server :: NodeConfig -> Manager -> Server NodeAPI
server config manager =
         nodeService config
    :<|> translators config manager

app :: NodeConfig -> Manager -> Application
app config manager = serve nodeAPI $ server config manager

node :: NodeConfig -> IO ()
node config = do
    manager <- newManager defaultManagerSettings
    run (nodePort config) (app config manager)
