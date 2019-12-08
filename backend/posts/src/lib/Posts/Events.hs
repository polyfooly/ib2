-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}

module Posts.Events where

import Data.Aeson
import GHC.Generics

import IB2.Service.Events

import Posts.Types


data TestEvent = TestEvent { testVar :: Int }
    deriving (Generic, ToJSON, FromJSON)
instance Event' TestEvent where
    eventType = const "testEvent"

data PostPosted = PostPosted
    { post :: Post
    } deriving (Generic, ToJSON, FromJSON)
instance Event' PostPosted where 
    eventType = const "postPosted"

data PostDeleted = PostDeleted
    { deletedPostId :: Int
    } deriving (Generic, ToJSON, FromJSON)
instance Event' PostDeleted where
    eventType = const "postDeleted"
