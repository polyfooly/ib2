-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module FrontendHost where

import Servant
import Network.Wai.Application.Static
import WaiAppStatic.Types
import Network.Wai.Handler.Warp (run)

import FrontendHost.API


server :: String -> Server FrontendHostAPI
server dir = serveDirectoryWith serveSettings
    where
        serveSettings = defSettings { ssLookupFile = lookupFile }
        defSettings = (defaultFileServerSettings dir)
        lookupFile p = do
            f <- ssLookupFile defSettings p
            case f of
                LRFile _ -> return f
                _ -> ssLookupFile defSettings [unsafeToPiece "index.html"]

app :: String -> Application
app dir = serve frontendHostAPI $ server dir

hostFrontend :: Int -> String -> IO ()
hostFrontend port dir = run port $ app dir
