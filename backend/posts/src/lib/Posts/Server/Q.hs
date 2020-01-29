-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE RecordWildCards #-}

module Posts.Server.Q where

import Data.List
import Data.Maybe

import Servant
import Servant.Pagination

import IB2.Service.Types
import IB2.Service.Events

import Posts.API
import Posts.Types as P


postsQServer :: MState m v 
    => EventSettings
    -> v PostsState -> ServerT PostsQAPI IO
postsQServer EventSettings{..} mstate = 
         postById
    :<|> ( threadById
    :<|> recentThreadsByTag )
    -- :<|> threadMetadataById
    where
        postById :: PostID -> IO (Maybe P.Post)
        postById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . hashedPost) $ posts st

        threadById :: PostID -> IO (Maybe Thread)
        threadById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . hashedPost . opPost) $ threads st

        {- threadMetadataById :: PostID -> IO (Maybe ThreadMetadata)
        threadMetadataById id' = do
            thread <- threadById id'
            pure $ threadMetadata <$> thread -}

        recentThreadsByTag ::
               PostTag -> Maybe Int
            -> Maybe (Ranges '["date"] Thread) 
            -> IO (Headers RecentOpsHeaders [Thread])
        recentThreadsByTag tag postsAmount mrange = do
            st <- getSt
            let range = fromMaybe recentOpsDefaultRange (mrange >>= extractRange)
                ths = filter
                    (elem tag . postTags . postData . hashedPost . opPost) $
                    threads st
                thsPage = applyRange range ths
                result = case postsAmount of
                    Just n -> map (\th -> th
                        { threadPosts = take n $ threadPosts th })
                        thsPage
                    Nothing -> thsPage

            addHeader (length ths) <$> returnRange range result

        getSt = runSt $ readSt mstate
