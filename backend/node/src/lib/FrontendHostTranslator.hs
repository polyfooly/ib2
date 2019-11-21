{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}

module FrontendHostTranslator where

import Servant
--import Servant.Server
--import Servant.Client

import Network.HTTP.Client (Manager)
import Network.HTTP.ReverseProxy (WaiProxyResponse(..), defaultOnExc, waiProxyTo, ProxyDest(..))

import Network.Wai.Internal (Request)

import FrontendHost.API


translateRequest :: Int -> Request -> IO WaiProxyResponse
translateRequest port _ = pure . WPRProxyDest . ProxyDest "127.0.0.1" $ port

frontendHostTranslator :: Int -> Manager -> ServerT FrontendHostAPI m
frontendHostTranslator port manager =
  Tagged $ waiProxyTo (translateRequest port) defaultOnExc manager
