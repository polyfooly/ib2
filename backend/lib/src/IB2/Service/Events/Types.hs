-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module IB2.Service.Events.Types where

import Data.Aeson
import GHC.Generics

import Database.EventStore


data EventStoreConfig = EventStoreConfig
    { hostAdress    :: String
    , hostPort      :: Int 
    , credsLogin    :: String
    , credsPassword :: String
    } deriving (Generic, ToJSON, FromJSON)

class (ToJSON d, FromJSON d) => Event' d where
    eventType :: d -> EventType

    create :: d -> Event
    create d = createEvent (eventType (undefined :: d)) Nothing (withJson d)

    parse :: ResolvedEvent -> Maybe d
    parse = resolvedEventDataAsJson
