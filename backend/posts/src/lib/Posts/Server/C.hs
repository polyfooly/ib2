-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}

module Posts.Server.C where

import Data.Time
import Data.Hashable
import Data.Either.Combinators

import Database.EventStore

import Servant

import IB2.Service.Server
import IB2.Service.Types
import IB2.Service.Events

import Posts.API
import Posts.Types
import Posts.Events
import Posts.Utils


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

                    let timedPost = post { postDate = timestamp }
                        newPostHash = toInteger $ hash timedPost
                        newPost = HashedPost
                            { postData = timedPost
                            , postId = newPostHash }
                        evt = create $ PostPosted newPost

                    sending <- sendEvent eventConn streamName anyVersion evt Nothing
                    res <- waitCatch sending

                    pure $ newPostHash <$ rightToMaybe res
                else pure Nothing
