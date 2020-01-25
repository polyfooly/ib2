-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}

module IB2.Service.Events.Types where

import Data.Aeson
import Data.Proxy
import GHC.Generics

import Database.EventStore


data EventSettings = EventSettings
    { streamName :: StreamName
    , eventConn :: Connection }

data EventStoreConfig = EventStoreConfig
    { hostAdress    :: String
    , hostPort      :: Int 
    , credsLogin    :: String
    , credsPassword :: String
    } deriving (Generic, ToJSON, FromJSON)

class (ToJSON e, FromJSON e) => Event' e where
    eventType :: Proxy e -> EventType

    create :: e -> Event
    create evt = createEvent (eventType (Proxy @e)) Nothing (withJson evt)

    parse :: ResolvedEvent -> Maybe e
    parse = resolvedEventDataAsJson
