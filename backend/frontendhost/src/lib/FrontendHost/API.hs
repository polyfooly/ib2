module FrontendHost.API where

import Servant

type FrontendHostAPI = Raw
frontendHostAPI :: Proxy FrontendHostAPI
frontendHostAPI = Proxy
