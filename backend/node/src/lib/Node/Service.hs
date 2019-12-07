-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Node.Service where

import Servant.Server

import Node.API
import Node.Types


nodeService :: NodeConfig -> Server NodeServiceAPI
nodeService config =
    getEventsConfig
        where getEventsConfig = do
                return $ eventsConfig config
