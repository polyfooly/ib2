{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}

module FrontendHost where

import Servant
import Network.Wai.Handler.Warp (run)

type FrontendHostAPI = Raw
frontendHostAPI :: Proxy FrontendHostAPI
frontendHostAPI = Proxy

server :: String -> Server FrontendHostAPI
server dir = serveDirectoryFileServer dir

app :: String -> Application
app dir = serve frontendHostAPI $ server dir

hostFrontend :: Int -> String -> IO ()
hostFrontend port dir = run port $ app dir
