-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Node where

import Servant
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Client (Manager, newManager, defaultManagerSettings)

import Translators (translators)
import Node.API

import Node.Config

app :: NodeConfig -> Manager -> Application
app config manager = serve nodeAPI $ translators config manager 

node :: NodeConfig -> IO ()
node config = do
  manager <- newManager defaultManagerSettings
  run (nodePort config) (app config manager)
