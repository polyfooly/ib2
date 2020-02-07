-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Posts.Utils where

import Data.List
import Data.List.Index

import Posts.Types


isCorrectParent _ 0 = True
isCorrectParent posts' id' = id' `elem` map (postId . hashedPost) posts'

isThreadReplyId threads' id' = id' `elem` filter (/= 0) (
    map (parentId . postData . hashedPost . opPost) threads')

modifyThread id' threads' f =
    case findIndex ((==) id' . postId . hashedPost . opPost) threads' of
        Just idx -> modifyAt idx f threads' 
        Nothing -> threads'

appendToThread post threads' = 
    modifyThread (parentId $ postData $ hashedPost post) threads' $ \th -> th  
        { threadPosts = post : threadPosts th
        , threadMetadata = 
            let md = threadMetadata th
            in md { postCount = postCount md + 1 }
        }

addSubThread thread threads' =
    let newThreadOp = opPost thread
        newThreadId = postId $ hashedPost newThreadOp
    in modifyThread (parentId $ postData $ hashedPost $ newThreadOp) threads' $ \th -> th
        { threadMetadata =
            let md = threadMetadata th
            in md { subthreads = newThreadId : subthreads md }
        }

createNewThread post = Thread
    { opPost = post
    , threadPosts = []
    , threadMetadata = ThreadMetadata
        { postCount = 0
        , subthreads = [] }
    }
