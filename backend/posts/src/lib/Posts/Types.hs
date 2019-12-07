-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module Posts.Types where

import Data.Text
import Data.Aeson
import GHC.Generics


data Post = Post
    { postText :: Text
    , postId :: Int
    } deriving (Generic, ToJSON, FromJSON)

data Thread = Thread
    { opPost :: Post
    , threadPosts :: [Post]
    } deriving (Generic, ToJSON, FromJSON)

data PostsState = PostsState
    { posts :: [Post]
    , threads :: [Thread] }
