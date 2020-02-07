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
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE TypeFamilies #-}

module Posts.Events.Handlers where

import Data.Proxy
import Data.Kind

import IB2.Service.Reducer
import IB2.Service.Events

import Posts.Events
import Posts.Types
import Posts.Utils

-- TODO: rewrite handleable abstraction with eventType as typeclass param
-- and corresponding event structure as associate type, handle using Alternative
instance Handleable PostPosted PostsState where
    handle event state = runSt $ do
        st' <- readSt state
        
        let hashedNewPost = postedPost event
            parent = parentId $ postData hashedNewPost

        if isCorrectParent (posts st') parent
            then modifySt state $ \st ->
                let newLastIndex = postsLastIndex st + 1
                    posts' = posts st
                    threads' = threads st
                    newPost = Post
                        { hashedPost = hashedNewPost
                        , postIndex = newLastIndex }

                    newThreads = case parent of
                        0 -> createNewThread newPost : threads'
                            (isThreadReplyId threads' -> True) ->
                            let newThread = createNewThread newPost
                            in newThread : 
                                addSubThread newThread
                                (appendToThread newPost threads')
                        _ -> appendToThread newPost threads'
                in st
                    { posts = newPost : posts'
                    , threads = newThreads
                    , postsLastIndex = newLastIndex }
            else pure ()

instance Handleable PostDeleted PostsState where
    handle event state =
        -- todo: delete from thread, counters, etc.
        runSt $ modifySt state $ \st -> st
            { posts = filter
                ((/=) (deletedPostId event) . postId . hashedPost)
                (posts st) }

instance Handleable TestEvent PostsState where
    handle _ _ =
        putStrLn "test event handled"


-- todo: get rid of (why did i do this...)
type family AllHandleable (ts :: [*]) s :: Constraint
type instance AllHandleable '[] s = ()
type instance AllHandleable (t ': ts) s = (Handleable t s, AllHandleable ts s)

data Events :: [*] -> * -> * where
    C :: AllHandleable (t ': ts) s => Proxy t -> Events ts s -> Events (t ': ts) s
    N :: Events '[] s

hSelector :: MState m v => Events ts s -> HandlerSelector IO v s
hSelector (C p c) t def = tryAs p t $ hSelector c t def
hSelector _ _ def = def

postsEvents = C
    (Proxy @PostPosted) $ C
    (Proxy @PostDeleted) $ C
    (Proxy @TestEvent) $ N

postsSelector :: MState m v => HandlerSelector IO v PostsState
postsSelector = hSelector postsEvents

postsHandleResolved :: MState m v => ResolvedHandler IO v PostsState
postsHandleResolved = handleResolved postsSelector
