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
        indexPiece = [unsafeToPiece "index.html"]
        defSettings = (defaultFileServerSettings dir)
        lookupFile p = do
            f <- ssLookupFile defSettings p
            let defAction = ssLookupFile defSettings indexPiece
            case f of
                LRFile _ -> return f
                -- a workaround to fix an issue with relative links in index.html
                -- when falling back to it from nonexistent route
                LRNotFound -> if length p > 1
                    then lookupFile $ tail p
                    else defAction
                _ -> defAction

app :: String -> Application
app dir = serve frontendHostAPI $ server dir

hostFrontend :: Int -> String -> IO ()
hostFrontend port dir = run port $ app dir
