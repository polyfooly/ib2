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
    handle event state = runSt $ do 
        st' <- readSt state
        
        let hashedNewPost = postedPost event
            parent = parentId $ postData hashedNewPost
        
        if parent `elem` map (postId . hashedPost) (posts st')
            then modifySt state (\st ->
                let newLastIndex = postsLastIndex st + 1
                    newPost = Post
                        { hashedPost = hashedNewPost
                        , postIndex = newLastIndex }
                    -- todo: subthreads
                    threads' = case parent of
                        0 -> createNewThread newPost : threads st
                        _ -> appendToThreads newPost $ threads st
                in st
                    { posts = newPost : posts st
                    , threads = threads'
                    , postsLastIndex = newLastIndex })
            else pure ()

-- todo: subthreads
appendToThreads post threads' = 
    map (\th -> if (postId . hashedPost . opPost) th == (postId . hashedPost) post
        then th 
            { threadPosts = post : threadPosts th
            , threadMetadata = 
                let md = threadMetadata th
                in md { postCount = postCount md + 1 }
            }
        else th ) threads'

createNewThread post = Thread
    { opPost = post
    , threadPosts = []
    , threadMetadata = ThreadMetadata
        { postCount = 0
        , subthreads = [] }
    }

instance Handleable PostDeleted PostsState where
    handle event state =
        -- todo: delete from thread, counters, etc.
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
