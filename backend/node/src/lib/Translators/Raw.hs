-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}

module Translators.Raw (rawTranslator) where

import Servant

import Network.HTTP.Client (Manager)
import Network.HTTP.ReverseProxy
    (WaiProxyResponse(..), defaultOnExc, waiProxyTo, ProxyDest(..))

import Network.Wai.Internal (Request)


translateRequest :: Int -> Request -> IO WaiProxyResponse
translateRequest port _ = pure . WPRProxyDest . ProxyDest "127.0.0.1" $ port

rawTranslator :: Int -> Manager -> ServerT Raw m
rawTranslator port manager =
    Tagged $ waiProxyTo (translateRequest port) defaultOnExc manager
