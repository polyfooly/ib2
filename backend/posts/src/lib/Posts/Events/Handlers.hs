-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FunctionalDependencies #-}

module Posts.Events.Handlers where

import Control.Concurrent.STM

import Database.EventStore

import Posts.Events
import Posts.Types
import IB2.Service.Events


if' :: Bool -> a -> a -> a 
if' True e _ = e
if' False _ e = e


class (Monad m) => MStateM m where --Mutable state monad 
    runS :: m () -> IO ()

class (MStateM m) => MState m v where --Mutable state 
    modify :: v s -> (s -> s) -> m () 

class Event' e => Handleable e s where --Handleable event for specific service
    handle :: (MState m v) => e -> v s -> m ()


instance MStateM STM where 
    runS = atomically

instance MState STM TVar where
    modify = modifyTVar


instance Handleable PostPosted PostsState where
    handle event state = 
        let newPost = post event 
        in modify state (\st -> st { posts = newPost : posts st })

instance Handleable PostDeleted PostsState where
    handle event state =
        modify state (\st -> st
            { posts = filter ((/=) (deletedPostId event) . postId) (posts st) })

--  TODO: Refactor it all...
type ResolvedHandler m v s = ResolvedEvent -> v s -> m ()
type HandlerSelector m v s = EventType ->
     ResolvedHandler m v s -> ResolvedHandler m v s

maybeHandle :: forall e s m v. (Handleable e s, MState m v) => 
    e -> ResolvedHandler m v s
maybeHandle _ event state = do 
    let parsed = (parse event) :: Maybe e
    case parsed of
        Nothing -> return ()
        Just e -> handle e state

tryAs :: (Handleable e s, MState m v) =>
    e -> HandlerSelector m v s
tryAs hint t alt =
    if' (t == eventType hint) (maybeHandle hint) alt

handleResolved :: (MState m v) =>
       HandlerSelector m v s
    -> ResolvedHandler IO v s
handleResolved selector event state = do
    case fmap (UserDefined . recordedEventType) $ resolvedEventRecord event of
        Nothing -> return ()
        Just t -> runS $
            (selector t $ const . const $ return ()) event state
            
postsSelector :: HandlerSelector STM TVar PostsState  
postsSelector t alt = 
    tryAs (undefined :: PostPosted) t $
    tryAs (undefined :: PostDeleted) t $ alt 

postsHandleResolved :: ResolvedEvent -> TVar PostsState -> IO ()
postsHandleResolved = handleResolved postsSelector
