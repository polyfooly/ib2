-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module FrontendHost.API where

import Servant

type FrontendHostAPI = Raw
frontendHostAPI :: Proxy FrontendHostAPI
frontendHostAPI = Proxy
