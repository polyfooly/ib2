-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Node.Config where

data NodeConfig = NodeConfig {
  nodePort          :: Int,
  frontendHostPort  :: Int,
  postsPort         :: Int
}