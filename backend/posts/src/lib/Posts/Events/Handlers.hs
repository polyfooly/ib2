-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PartialTypeSignatures #-}

module Posts.Events.Handlers where

import Data.Proxy

import Posts.Events
import Posts.Types
import IB2.Service.Reducer
import IB2.Service.Events


-- TODO: rewrite handleable abstraction with eventType as typeclass param
-- and corresponding event structure as associate type
instance Handleable PostPosted PostsState where
    handle event state =
        runSt $ modifySt state (\st ->
            let newLastIndex = postsLastIndex st + 1
                newPost = Post
                    { hashedPost = postedPost event
                    , postIndex = newLastIndex }
            in st 
                { posts = newPost : posts st
                , postsLastIndex = newLastIndex 
                })

instance Handleable PostDeleted PostsState where
    handle event state =
        runSt $ modifySt state (\st -> st
            { posts = filter
                ((/=) (deletedPostId event) . postId . hashedPost)
                (posts st)
            })

instance Handleable TestEvent PostsState where
    handle _ _ =
        putStrLn "test event handled"


-- todo: rewrite
data Events :: [*] -> * -> * where
    C :: Handleable t s => Proxy t -> Events ts s -> Events (t ': ts) s
    S :: Handleable t s => Proxy t -> Events '[t] s

(|>) = C
p |* t = C p (S t)
infixr |>, |*
    
hSelector :: MState m v => Events ts s -> HandlerSelector IO v s
hSelector (S p) t def = tryAs p t def
hSelector (C p c) t def = tryAs p t $ hSelector c t def

postsEvents :: Events _ PostsState
postsEvents = Proxy @PostPosted 
           |> Proxy @PostDeleted
           |* Proxy @TestEvent 

postsSelector :: MState m v => HandlerSelector IO v PostsState
postsSelector = hSelector postsEvents

postsHandleResolved :: MState m v => ResolvedHandler IO v PostsState
postsHandleResolved = handleResolved postsSelector
