-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module Posts where

import Data.Time

import Network.Wai.Handler.Warp (run)
import Control.Concurrent.STM
import Control.Concurrent.Async (concurrently_)

import Servant
import Database.EventStore

import IB2.Service
import IB2.Service.Types
import IB2.Service.Events

import Posts.API
import Posts.Server
import Posts.Events.Handlers
import Posts.Types as P


app :: EventSettings -> TVar PostsState -> Application
app conf mstate = serve postsAPI $ postsServer conf mstate

postsReducer :: EventSettings -> TVar PostsState -> IO ()
postsReducer conf mstate = reducer conf mstate postsHandleResolved

defaultDate = UTCTime (fromGregorian 0 0 0) 0
defaultPost = P.Post (HashedPost (PostData defaultDate [] "" 0 []) 1) 1
defaultState = PostsState 
    { posts = [ defaultPost ]
    , postsLastIndex = 0
    , threads = [] }

postsService :: ServiceSettings -> IO ()
postsService ServiceSettings{..} = do
    let connSettings = defaultSettings
            { s_defaultUserCredentials = Just $ eventCreds }

    conn <- connect connSettings (Static "127.0.0.1" $ eventPort)
    mstate <- initStIO defaultState

    let eventSettings = EventSettings
            { streamName = "posts"
            , eventConn = conn }

    concurrently_ (run webPort
        (app eventSettings mstate)) 
        (postsReducer eventSettings mstate)
