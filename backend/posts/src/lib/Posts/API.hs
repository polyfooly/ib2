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
        Capture "id" PostID :> Get '[JSON] (Maybe P.Post) :<|>

        "ops" :> Capture "tag" PostTag :>
            Header "Range" (Ranges '["date"] P.Post) :>
            GetPartialContent '[JSON] (Headers RecentOpsHeaders [P.Post])
    ) :<|> 
    "threads" :> (
        Capture "id" PostID :> Get '[JSON] (Maybe Thread) :<|>
        Capture "id" PostID :> "replies" :> Get '[JSON] (Maybe [PostID])
    )

type RecentOpsHeaders =
    Header "Total-Count" Int ': PageHeaders '["date"] P.Post

type PostsCAPI = --Command API
    "post" :> ReqBody '[JSON] PostData :> Post '[JSON] (Maybe PostID)

type PostsAPI =
    "api" :> "v1" :> ( PostsTestAPI 
                  :<|> PostsCAPI 
                  :<|> PostsQAPI )

postsAPI = Proxy @PostsAPI
