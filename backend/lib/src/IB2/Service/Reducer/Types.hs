-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module IB2.Service.Reducer.Types where

import Control.Concurrent.STM

import Database.EventStore

import IB2.Service.Events


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

--  TODO: Refactor it all...
type ResolvedHandler m v s = ResolvedEvent -> v s -> m ()
type HandlerSelector m v s = EventType ->
     ResolvedHandler m v s -> ResolvedHandler m v s
    