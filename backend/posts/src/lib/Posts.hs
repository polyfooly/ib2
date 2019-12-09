-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
--TEMP
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Posts where

import Servant
import Network.Wai.Handler.Warp (run)
import Control.Concurrent.STM
import Control.Concurrent.Async (concurrently_)

import Database.EventStore

import IB2.Service.Reducer

import Posts.API
import Posts.Events.Handlers
import Posts.Types as P

--TEMP
import Control.Monad.IO.Class
import Control.Lens
import IB2.Types


testHandler = return "test"

defaultState = PostsState { posts = [ P.Post "empty" 0 ] }

serverT :: TVar PostsState -> ServerT PostsAPI STM
serverT state =
         testHandler
    :<|> getPost
    :<|> emptyServer'
         where
             getPost id' = do
                 st <- readTVar state
                 return $ (posts st) ^? element id'

stmToHandler :: STM a -> Handler a
stmToHandler = liftIO . atomically

server :: TVar PostsState -> Server PostsAPI
server state = hoistServer postsAPI stmToHandler $ serverT state

app :: TVar PostsState -> Application
app state = serve postsAPI $ server state

postsReducer :: Connection -> TVar PostsState -> IO ()
postsReducer conn state = reducer conn state "posts" postsHandleResolved

service :: Int -> IO ()
service port = do
    let creds = credentials "admin" "547455"
        settings = defaultSettings
            { s_defaultUserCredentials = Just creds }

    conn <- connect settings (Static "127.0.0.1" 5475)
    state <- newTVarIO defaultState

    concurrently_ (run port $ app state) (postsReducer conn state)
