-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module IB2.Posts.Server where

import Control.Concurrent.STM

import Database.EventStore

import Servant

import IB2.Posts.Types
import IB2.Posts.API
import IB2.Posts.Server.Q
import IB2.Posts.Server.C

import IB2.Service.Types
import IB2.Service.Server
import IB2.Service.Events


testHandler = return "test"

postsServer :: (MState m v)
    => EventSettings
    -> v PostsState
    -> ServerT PostsAPI Handler
postsServer conf mstate =
         testHandler
    :<|> postsSQRSServer conf mstate

postsSQRSServer conf mstate = cqrsIOServerSt
    (Proxy @(PostsCAPI :<|> PostsQAPI)) 
    postsCServer postsQServer
    conf mstate
