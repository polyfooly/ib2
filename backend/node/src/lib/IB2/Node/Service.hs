-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module IB2.Node.Service where

import Servant.Server

import IB2.Node.API
import IB2.Node.Types


nodeService :: NodeConfig -> Server NodeServiceAPI
nodeService config =
    getEventsConfig
        where getEventsConfig =
                pure $ eventsConfig config
