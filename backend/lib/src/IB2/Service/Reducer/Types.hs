-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}

module IB2.Service.Reducer.Types where

import Control.Concurrent.STM

import Database.EventStore

import IB2.Service.Events


class (Monad m) => MStateM m where --Mutable state monad 
    runSt :: m s -> IO s

class (MStateM m) => MState m v | v -> m where --Mutable state container (e.g. TVar)
    modifySt :: v s -> (s -> s) -> m () 
    readSt :: v s -> m s
    initStIO :: s -> IO (v s)

class Event' e => Handleable e s where --Handleable event for specific service
    handle :: (MState m v) => e -> v s -> IO ()


instance MStateM STM where 
    runSt = atomically
    
instance MState STM TVar where
    modifySt = modifyTVar
    readSt = readTVar
    initStIO = newTVarIO

type ResolvedHandler m v s = ResolvedEvent -> v s -> m ()
type HandlerSelector m v s = EventType ->
     ResolvedHandler m v s -> ResolvedHandler m v s
    