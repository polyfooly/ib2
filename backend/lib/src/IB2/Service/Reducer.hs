-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RecordWildCards #-}

module IB2.Service.Reducer 
    ( module IB2.Service.Reducer
    , module IB2.Service.Reducer.Types
    ) where

import Control.Monad
import Control.Concurrent.STM.Lock
import Control.Concurrent.STM

import Data.Proxy

import Database.EventStore

import IB2.Service.Reducer.Types
import IB2.Service.Events


maybeHandle :: forall e s m v. (Handleable e s, MState m v) 
    => Proxy e -> ResolvedHandler IO v s
maybeHandle _ event state = do --try to handle as specific event
    let parsed = (parse event) :: Maybe e
    case parsed of
        Nothing -> return ()
        Just e -> handle e state
        
tryAs :: (Handleable e s, MState m v)
    => Proxy e -> HandlerSelector IO v s
tryAs hint t def = --try to handle as handleable or compute default
    if t == eventType hint then
         maybeHandle hint
    else def

emptyHandler :: (MState m v) => ResolvedHandler IO v s
emptyHandler _ _ = return () 

handleResolved :: (MState m v)
    => HandlerSelector IO v s
    -> ResolvedHandler IO v s
handleResolved selector event state = do
    case UserDefined . recordedEventType <$> resolvedEventRecord event of
        Nothing -> return ()
        Just t ->
            -- select one of selector handlers or do nothing
            (selector t emptyHandler) event state


reducer :: (MState m v)
    => EventSettings -> v s
    -- replay ready flag
    -> Lock
    -> ResolvedHandler IO v s 
    -> IO ()
reducer EventSettings{..} state serverLock handler = do
    -- replay from the beginning
    subscription <- subscribeFrom eventConn streamName True Nothing Nothing Nothing

    let nextEvent' = nextEvent subscription
        handleEvent = flip handler state
        handleNext = nextEvent' >>= handleEvent

        -- TODO: rewrite in a more functional/lazy manner,
        --       monitor event replay progress
        replayEvents = do
            caughtUp <- hasCaughtUp subscription
            unless caughtUp $ handleNext >> replayEvents
        
        handleUpstream = void $ forever handleNext

        unlockServer = atomically $ do
            isLocked <- locked serverLock
            when isLocked $ release serverLock

    replayEvents
    unlockServer

    handleUpstream
