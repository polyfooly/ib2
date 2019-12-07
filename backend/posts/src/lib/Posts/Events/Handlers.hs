-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Posts.Events.Handlers where

import Control.Concurrent.STM
--import Control.Concurrent.Async ()

import Database.EventStore

import Posts.Events
import Posts.Types
import IB2.Service.Events


handlePosted :: PostPosted -> TVar PostsState -> STM ()
handlePosted event state = do
    let newPost = post event
    modifyTVar state (\st -> st { posts = newPost : posts st })

handleDeleted :: PostDeleted -> TVar PostsState -> STM ()
handleDeleted event state =
    modifyTVar state (\st -> st
        { posts = filter ((/=) (deletedPostId event) . postId) (posts st) })

maybeHandle :: (Event' a) => 
    a -> ResolvedEvent -> TVar PostsState ->
    (a -> TVar PostsState -> STM ()) -> STM ()

maybeHandle hint event state handler = do 
    let parsed = parse event
    case parsed of
        Nothing -> return ()
        Just e -> handler e state

handleResolved :: ResolvedEvent -> TVar PostsState -> IO ()
handleResolved event state = do
    let recordType = fmap (UserDefined . recordedEventType) $ resolvedEventRecord event
    case recordType of
        Nothing -> return ()
        Just r -> 
            atomically $
                let hint = undefined :: PostPosted
                in if r == eventType hint then 
                    maybeHandle hint event state handlePosted
                else return ()
                