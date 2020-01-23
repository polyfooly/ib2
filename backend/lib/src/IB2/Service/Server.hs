-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}

module IB2.Service.Server  where

import Database.EventStore

import Control.Monad.Trans.Except
import Control.Exception (try)

import Servant


emptyServer' :: Monad m => m String
emptyServer' = return "empty"

ioToHandler :: IO a -> Handler a
ioToHandler = Handler . ExceptT . try

cqrsIOServerSt :: (HasServer api '[], ServerT api IO ~ (c :<|> q))
    => Proxy api 
    -> (s -> v -> c) -> (s -> v -> q)
    -> s -> v
    -> ServerT api Handler
cqrsIOServerSt api cs qs conf st =
    hoistServer api ioToHandler
        (cs conf st :<|> qs conf st)
