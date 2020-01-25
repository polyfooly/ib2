-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}

module Posts.Server.C where

import Data.Time
import Data.Hashable

import Database.EventStore

import Servant

import IB2.Service.Server
import IB2.Service.Types
import IB2.Service.Events
import IB2.Service.Events.Types

import Posts.API
import Posts.Types
import Posts.Events


postsCServer :: (MState m v)
    => EventSettings -> v PostsState -> ServerT PostsCAPI IO
postsCServer EventSettings{..} mstate =
    postPost
    where
        postPost post = do
            timestamp <- getCurrentTime

            let timedPost = post { postDate = timestamp }
                newPostHash = hash timedPost
                newPost = HashedPost
                    { postData = timedPost
                    , postId = newPostHash }
                evt = create $ PostPosted newPost

            sending <- sendEvent eventConn streamName anyVersion evt Nothing
            res <- waitCatch sending

            pure $ case res of
                Left _ -> Nothing
                Right _ -> Just newPostHash
