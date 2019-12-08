-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}

module Posts.Events.Handlers where

import Control.Concurrent.STM
import Control.Monad.IO.Class

import Database.EventStore

import Posts.Events
import Posts.Types
import IB2.Service.Events


-- TODO: abstract data representaion
class Event' e => Handleable e s where 
    handle :: e -> TVar s -> STM ()

instance Handleable PostPosted PostsState where
    handle event state = do
        let newPost = post event
        modifyTVar state (\st -> st { posts = newPost : posts st })

instance Handleable PostDeleted PostsState where
    handle event state =
        modifyTVar state (\st -> st
            { posts = filter ((/=) (deletedPostId event) . postId) (posts st) })


maybeHandle :: forall e s. (Handleable e s) => 
    e -> ResolvedEvent -> TVar s -> STM ()
maybeHandle hint event state = do 
    let parsed = (parse event) :: Maybe e
    case parsed of
        Nothing -> return ()
        Just e -> handle e state


if' :: Bool -> a -> a -> a 
if' True e _ = e
if' False _ e = e

selectHandler ::
      (Handleable h s) => h 
    -> EventType -> (ResolvedEvent -> TVar s -> STM ())
    -> ResolvedEvent -> TVar s -> STM ()
selectHandler hint t alt =
    if' (t == eventType hint) (maybeHandle hint) alt

type HandlerSelector s = EventType
    -> (ResolvedEvent -> TVar s -> STM ())
    -> ResolvedEvent -> TVar s -> STM ()

handleResolved :: 
       HandlerSelector s -> ResolvedEvent -> TVar s -> IO ()
handleResolved selector event state = do
    case fmap (UserDefined . recordedEventType) $ resolvedEventRecord event of
        Nothing -> return ()
        Just t -> atomically $
            (selector t $ const . const $ return ()) event state

postsSelector :: HandlerSelector PostsState    
postsSelector t alt = 
    selectHandler (undefined :: PostPosted) t $
    selectHandler (undefined :: PostDeleted) t $ alt

postsHandleResolved = handleResolved postsSelector
