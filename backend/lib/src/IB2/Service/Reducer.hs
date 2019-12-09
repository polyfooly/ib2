-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

module IB2.Service.Reducer 
    ( module IB2.Service.Reducer
    , module IB2.Service.Reducer.Types
    ) where

import Database.EventStore

import IB2.Service.Reducer.Types
import IB2.Service.Events


maybeHandle :: forall e s m v. (Handleable e s, MState m v) => 
    e -> ResolvedHandler m v s
maybeHandle _ event state = do --try to handle as specific event
    let parsed = (parse event) :: Maybe e
    case parsed of
        Nothing -> return ()
        Just e -> handle e state

if' :: Bool -> a -> a -> a 
if' True e _ = e
if' False _ e = e
        
tryAs :: (Handleable e s, MState m v) =>
    e -> HandlerSelector m v s
tryAs hint t next = --try to handle as specific event or return next
    if' (t == eventType hint) (maybeHandle hint) next

handleResolved :: (MState m v) =>
       HandlerSelector m v s
    -> ResolvedHandler IO v s
handleResolved selector event state = do
    case fmap (UserDefined . recordedEventType) $ resolvedEventRecord event of
        Nothing -> return ()
        Just t -> runS $
            --select one of selector handlers or do nothing
            (selector t $ const . const $ return ()) event state


reducer ::
       Connection -> v s -> StreamName 
    -> ResolvedHandler IO v s 
    -> IO ()
reducer conn state streamName handler = do
    --let evt = create $ PostPosted $ P.Post "text" 0
    --as <- sendEvent conn streamName anyVersion evt $ Nothing
    --wait as >> putStrLn "passed"

    --replaySubscription <- subscribeFrom 
    --    conn streamName True Nothing Nothing Nothing
    upstreamSubscription <- subscribe conn streamName True Nothing

    let loop :: IO () 
        loop = do
            event <- nextEvent upstreamSubscription
            handler event state
            loop
    loop

    return ()
