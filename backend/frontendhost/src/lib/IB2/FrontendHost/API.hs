-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module IB2.FrontendHost.API where

import Servant


type FrontendHostAPI = Raw
frontendHostAPI = Proxy @FrontendHostAPI
