-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module IB2.Posts.Types where

import Data.Text (Text)
import Data.Aeson
import Data.Time
import Data.Proxy

import Data.Hashable

import GHC.Generics

import Servant.Pagination


type AttachmentID = Integer
type PostID = Integer
type PostIndex = Integer
type PostTag = Text
type PostDate = UTCTime

data PostData = PostData
    { postAttachments :: [AttachmentID]
    , postText :: Text
    , parentId :: PostID
    , postTags :: [PostTag]
    } deriving (Eq, Show, Generic, ToJSON, FromJSON, Hashable)

data AcceptedPost = AcceptedPost
    { postData :: PostData
    , postDate :: PostDate
    , postId :: PostID 
    } deriving (Eq, Show, Generic, ToJSON, FromJSON)

data Post = Post
    { acceptedPost :: AcceptedPost
    , postIndex :: PostIndex 
    } deriving (Eq, Show, Generic, ToJSON, FromJSON)

instance HasPagination Thread "date" where
    type RangeType Thread "date" = PostDate
    getFieldValue _ th = maximum $ map (postDate . acceptedPost) $
        opPost th : threadPosts th

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
