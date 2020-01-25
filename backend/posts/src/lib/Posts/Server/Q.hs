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

--import Database.EventStore

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
         ( postById
    :<|> recentOpsByTag )
    :<|> threadById
    :<|> threadRepliesById
    where
        postById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . hashedPost) $ posts st

        threadById id' = do
            st <- getSt
            pure $ find ((==) id' . postId . hashedPost . opPost) $ threads st

        threadRepliesById id' = do
            thread <- threadById id'
            pure $ map (postId . hashedPost) <$> threadPosts <$> thread

        recentOpsByTag ::
               PostTag
            -> Maybe (Ranges '["date"] P.Post) 
            -> IO (Headers RecentOpsHeaders [P.Post])
        recentOpsByTag tag mrange = do
            st <- getSt
            let range = fromMaybe recentOpsDefaultRange (mrange >>= extractRange)
                ops = filter (elem tag . postTags . postData . hashedPost) $ 
                      map opPost $ threads st

            addHeader (length ops) <$>
                returnRange range (applyRange range ops)

        getSt = runSt $ readSt mstate
