-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}

module Posts where

import Servant
import Network.Wai.Handler.Warp (run)

import Posts.API

server :: Server PostsAPI
server = return "POSTS test"

app :: Application
app = serve postsAPI $ server

posts :: Int -> IO ()
posts port = run port $ app