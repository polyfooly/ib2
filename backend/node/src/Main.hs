-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Main where

import Node
import Node.Config

main :: IO ()
main = node NodeConfig 
  { nodePort=5472
  , frontendHostPort=5473
  , postsPort=5474 
  }

