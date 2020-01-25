-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module IB2.Service.Types 
    ( module IB2.Service.Types
    , module IB2.Service.Reducer.Types
    , module IB2.Service.Server.Types ) where

import Servant

import Database.EventStore

import IB2.Service.Reducer.Types
import IB2.Service.Server.Types


data ServiceSettings = ServiceSettings 
    { webPort :: Int
    , eventPort :: Int 
    , eventCreds :: Credentials }
