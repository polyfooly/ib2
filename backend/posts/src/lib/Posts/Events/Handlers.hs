-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Posts.Events.Handlers where

import Control.Concurrent.STM

import Database.EventStore

import Posts.Events
import Posts.Types
import IB2.Service.Reducer


instance Handleable PostPosted PostsState where
    handle event state = 
        let newPost = post event 
        in modify state (\st -> st { posts = newPost : posts st })

instance Handleable PostDeleted PostsState where
    handle event state =
        modify state (\st -> st
            { posts = filter ((/=) (deletedPostId event) . postId) (posts st) }) 
            
postsSelector :: HandlerSelector STM TVar PostsState  
postsSelector t alt = 
    tryAs (undefined :: PostPosted) t $
    tryAs (undefined :: PostDeleted) t $ alt 

postsHandleResolved :: ResolvedEvent -> TVar PostsState -> IO ()
postsHandleResolved = handleResolved postsSelector
