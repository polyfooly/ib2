{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}

module Node where

import Servant
--import Servant.Client
import Network.Wai.Handler.Warp (run)
import Network.HTTP.Client (Manager, newManager, defaultManagerSettings)

import FrontendHostTranslator
import FrontendHost.API



type NodeAPI =
       "test" :> Get '[JSON] Int
  :<|> FrontendHostAPI

nodeAPI :: Proxy NodeAPI
nodeAPI = Proxy

handlers :: Int -> Manager -> Server NodeAPI
handlers port manager =
       return 547455
  :<|> frontendHostTranslator port manager

app :: Int -> Manager -> Application
app port manager = serve nodeAPI $ handlers port manager

data NodeConfig = NodeConfig {
  nodePort :: Int,
  hostPort :: Int
}

node :: NodeConfig -> IO ()
node config = do
  manager <- newManager defaultManagerSettings
  run (nodePort config) (app (hostPort config) manager)
