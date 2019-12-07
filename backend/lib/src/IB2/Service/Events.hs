-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ScopedTypeVariables #-}

module IB2.Service.Events where

import Database.EventStore
import Data.Aeson


createEvent' :: (ToJSON d) => EventType -> d -> Event
createEvent' type' data' = createEvent type' Nothing (withJson data')

class (ToJSON d, FromJSON d) => Event' d where
    eventType :: d -> EventType

    create :: d -> Event
    create = createEvent' (eventType (undefined :: d))

    parse :: ResolvedEvent -> Maybe d
    parse = resolvedEventDataAsJson
