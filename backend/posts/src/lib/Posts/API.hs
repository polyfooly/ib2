-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module Posts.API where

import Servant
import Servant.Pagination

import Posts.Types hiding (Post)
import qualified Posts.Types as P

import IB2.Service.Server.Types


type PostsTestAPI = "postTest" :> Get '[JSON] String

type PostsQAPI = --Query API
    "posts" :> (
        Capture "id" PostID :> Get '[JSON] (Maybe P.Post)
    ) :<|> 
    "threads" :> (
        Capture "id" PostID :> Get '[JSON] (Maybe Thread) :<|>
        "recent" :> 
            Capture "tag" PostTag :>
            QueryParam "posts_amount" Int :>
            Header "Range" (Ranges '["date"] Thread) :>
            GetPartialContent '[JSON] (Headers RecentOpsHeaders [Thread]) {- :<|>
        Capture "id" PostID :> "metadata" :> Get '[JSON] (Maybe ThreadMetadata) -}
    )

type RecentOpsHeaders =
    Header "Total-Count" Int ': PageHeaders '["date"] Thread

type PostsCAPI = --Command API
    "post" :> ReqBody '[JSON] PostData :> Post '[JSON] (Maybe PostID)

type PostsCQAPI = PostsCAPI :<|> PostsQAPI

type PostsAPI =
    "api" :> "v1" :> ( PostsTestAPI 
                  :<|> PostsCQAPI )

postsAPI = Proxy @PostsAPI
