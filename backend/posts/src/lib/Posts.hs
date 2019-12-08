-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveGeneric #-}
--TEMP
{-# LANGUAGE OverloadedStrings #-}
--{-# LANGUAGE ImpredicativeTypes #-}
--{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Posts where

import Servant
import Network.Wai.Handler.Warp (run)
import Control.Concurrent.STM
import Control.Concurrent.Async (wait, concurrently_)

import Posts.API
import Posts.Events
import Posts.Events.Handlers
import Posts.Types as P

--TEMP
import Database.EventStore
--import Data.Aeson
--import GHC.Generics
import IB2.Service.Events
import Control.Monad.IO.Class
import Control.Lens
import Servant.Server
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

--TODO: Refactor - move generic parts to ib2-lib package
devReducer :: Connection -> TVar PostsState -> IO ()
devReducer conn state = do
    let streamName = "posts"

    --let evt = create $ PostPosted $ P.Post "text" 0
    --as <- sendEvent conn streamName anyVersion evt $ Nothing
    --wait as >> putStrLn "passed"

    --replaySubscription <- subscribeFrom 
    --    conn streamName True Nothing Nothing Nothing
    upstreamSubscription <- subscribe conn streamName True Nothing

    let loop :: IO ()
        loop = do
            event <- nextEvent upstreamSubscription
            postsHandleResolved event state
            loop
    loop

    return ()

service :: Int -> IO ()
service port = do
    let creds = credentials "admin" "547455"
        settings = defaultSettings
            { s_defaultUserCredentials = Just creds }

    conn <- connect settings (Static "127.0.0.1" 5475)
    state <- newTVarIO defaultState

    concurrently_ (run port $ app state) (devReducer conn state)
