{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}

module Node where

import Servant
import Servant.Client
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Client (Manager, newManager, defaultManagerSettings)

import FrontendHostTranslator

type NodeAPI = FrontendHostAPI

nodeAPI :: Proxy NodeAPI
nodeAPI = Proxy

app :: Int -> Manager -> Application
app port manager = serve nodeAPI $ (frontendHostTranslator port manager)

data NodeConfig = NodeConfig {
  nodePort :: Int,
  hostPort :: Int
}

node :: NodeConfig -> IO ()
node config = do
  manager <- newManager defaultManagerSettings
  run (nodePort config) (app (hostPort config) manager)
