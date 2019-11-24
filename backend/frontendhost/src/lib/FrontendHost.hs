-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
--{-# LANGUAGE DeriveGeneric #-}

module FrontendHost where

import Servant
import Network.Wai.Handler.Warp (run)

import FrontendHost.API


server :: String -> Server FrontendHostAPI
server = serveDirectoryFileServer

app :: String -> Application
app dir = serve frontendHostAPI $ server dir

hostFrontend :: Int -> String -> IO ()
hostFrontend port dir = run port $ app dir
