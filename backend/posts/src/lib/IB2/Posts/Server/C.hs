-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RecordWildCards #-}

module IB2.Posts.Server.C where

import Data.Time
import Data.Hashable
import Data.Either.Combinators

import Database.EventStore

import Servant

import IB2.Service.Server
import IB2.Service.Types
import IB2.Service.Events

import IB2.Posts.API
import IB2.Posts.Types
import IB2.Posts.Events
import IB2.Posts.Utils


postsCServer :: (MState m v)
    => EventSettings -> v PostsState -> ServerT PostsCAPI IO
postsCServer EventSettings{..} mstate =
    postPost
    where
        postPost :: PostData -> IO (Maybe PostID)
        postPost post = do
            st <- runSt $ readSt mstate

            if isCorrectParent (posts st) (parentId post)
                then do
                    timestamp <- getCurrentTime

                    let newPostHash = toInteger $ hash post
                        newPost = AcceptedPost
                            { postData = post
                            , postDate = timestamp
                            , postId = newPostHash }
                        evt = create $ PostPosted newPost

                    sending <- sendEvent eventConn streamName anyVersion evt Nothing
                    res <- waitCatch sending

                    pure $ newPostHash <$ rightToMaybe res
                else pure Nothing
