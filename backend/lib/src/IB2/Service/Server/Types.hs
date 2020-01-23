-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module IB2.Service.Server.Types where

import Servant

type EmptyAPI' = "empty" :> Get '[JSON] String
