-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Main where

import Node
import Node.Types


main :: IO ()
main = node NodeConfig 
    { nodePort         = 5472
    , frontendHostPort = 5473
    , postsPort        = 5474
    , eventsConfig     = EventStoreConfig
        { hostAdress    = "127.0.0.1"
        , hostPort      = 5475
        , credsLogin    = "admin"
        , credsPassword = "547455"
        }
    }
