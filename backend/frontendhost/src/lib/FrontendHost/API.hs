-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module FrontendHost.API where

import Servant


type FrontendHostAPI = Raw
frontendHostAPI = Proxy @FrontendHostAPI
