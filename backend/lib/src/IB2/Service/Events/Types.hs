-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module IB2.Service.Events.Types where

import Data.Aeson
import GHC.Generics

data EventStoreConfig = EventStoreConfig
    { hostAdress    :: String
    , hostPort      :: Int 
    , credsLogin    :: String
    , credsPassword :: String
    } deriving (Generic, ToJSON, FromJSON)
    