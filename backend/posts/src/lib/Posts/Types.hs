-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
--{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Posts.Types where

import Data.Text (Text)
import Data.Aeson
import Data.Time
import Data.Proxy

import Servant hiding (Post)

import Data.Hashable
import Data.Hashable.Time()

import GHC.Generics

import Servant.Pagination


type AttachmentID = Integer
type PostID = Integer
type PostIndex = Integer
type PostTag = Text
type PostDate = UTCTime

data PostData = PostData
    { postDate :: PostDate
    , postAttachments :: [AttachmentID]
    , postText :: Text
    , parentId :: PostID
    , postTags :: [PostTag]
    } deriving (Eq, Show, Generic, ToJSON, FromJSON, Hashable)

data HashedPost = HashedPost
    { postData :: PostData
    , postId :: PostID 
    } deriving (Eq, Show, Generic, ToJSON, FromJSON, Hashable)

data Post = Post
    { hashedPost :: HashedPost
    , postIndex :: PostIndex 
    } deriving (Eq, Show, Generic, ToJSON, FromJSON, Hashable)

instance HasPagination Thread "date" where
    type RangeType Thread "date" = PostDate
    getFieldValue _ = postDate . postData . hashedPost . opPost

recentOpsDefaultRange :: Range "date" PostDate
recentOpsDefaultRange = getDefaultRange (Proxy @Thread)

data Thread = Thread
    { opPost :: Post
    , threadPosts :: [Post]
    , threadMetadata :: ThreadMetadata
    } deriving (Eq, Show, Generic, ToJSON, FromJSON)

data ThreadMetadata = ThreadMetadata
    { postCount :: Int 
    , subthreads :: [PostID]
    } deriving (Eq, Show, Generic, ToJSON, FromJSON)

data PostsState = PostsState
    { posts :: [Post]
    , postsLastIndex :: PostIndex
    , threads :: [Thread] }
