-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Node.Types where

import IB2.Service.Events.Types


data NodeConfig = NodeConfig 
    { nodePort         :: Int
    , frontendHostPort :: Int
    , postsPort        :: Int
    , eventsConfig     :: EventStoreConfig 
    }
    