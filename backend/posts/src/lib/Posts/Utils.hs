-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module Posts.Utils where

import Data.List
import Data.List.Index

import Posts.Types


isCorrectParent _ 0 = True
isCorrectParent posts' id' = id' `elem` map (postId . acceptedPost) posts'

isThreadReplyId posts' id' =
    case find ((==) id' . postId . acceptedPost) posts' of
        Just extantPost -> (parentId . postData . acceptedPost) extantPost /= 0
        Nothing -> False

modifyThread id' threads' f =
    case findIndex ((==) id' . postId . acceptedPost . opPost) threads' of
        Just idx -> modifyAt idx f threads' 
        Nothing -> threads'

appendToThread post threads' = 
    modifyThread (parentId $ postData $ acceptedPost post) threads' $ \th -> th  
        { threadPosts = post : threadPosts th
        , threadMetadata = 
            let md = threadMetadata th
            in md { postCount = postCount md + 1 }
        }

addSubThread thread threads' =
    let newThreadOp = opPost thread
        newThreadId = postId $ acceptedPost newThreadOp
    in modifyThread (parentId $ postData $ acceptedPost $ newThreadOp) threads' $ \th -> th
        { threadMetadata =
            let md = threadMetadata th
            in md { subthreads = newThreadId : subthreads md }
        }

createNewThread opPost = Thread
    { opPost = opPost
    , threadPosts = []
    , threadMetadata = ThreadMetadata
        { postCount = 0
        , subthreads = [] }
    }
