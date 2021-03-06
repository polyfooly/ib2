-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RecordWildCards #-}

module IB2.Posts.Server.Q where

import Data.List
import Data.Maybe

import Servant
import Servant.Pagination

import IB2.Service.Types
import IB2.Service.Events

import IB2.Posts.API
import IB2.Posts.Types as P


postsQServer :: MState m v 
    => EventSettings
    -> v PostsState -> ServerT PostsQAPI IO
postsQServer EventSettings{..} mstate = 
         postById
    :<|> ( threadById
    :<|> recentThreadsByTag )
    where
        postById :: PostID -> IO (Maybe P.Post)
        postById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . acceptedPost) $ posts st

        threadById :: PostID -> IO (Maybe Thread)
        threadById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . acceptedPost . opPost) $ threads st

        recentThreadsByTag ::
               PostTag -> Maybe Int
            -> Maybe (Ranges '["date"] Thread) 
            -> IO (Paginated Thread)
        recentThreadsByTag tag postsAmount mrange = do
            st <- getSt
            let range = fromMaybe recentOpsDefaultRange (mrange >>= extractRange)
                ths = filter
                    (elem tag . postTags . postData . acceptedPost . opPost) $
                    threads st
                thsPage = applyRange range ths
                result = case postsAmount of
                    Just n -> map (\th -> th
                        { threadPosts = take n $ threadPosts th })
                        thsPage
                    Nothing -> thsPage

            pure $ Paginated result $ length ths

        getSt = runSt $ readSt mstate
