-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeApplications #-}

module IB2.Posts.API where

import Servant
import Servant.Pagination

import IB2.Posts.Types hiding (Post)
import qualified IB2.Posts.Types as P

import IB2.Service.Server.Types


type PostsTestAPI = "postTest" :> Get '[JSON] String

-- Query API
type PostsQAPI = 
    "posts" :> (
        Capture "id" PostID :> Get '[JSON] (Maybe P.Post)
    ) :<|> 
    "threads" :> (
        Capture "id" PostID :> Get '[JSON] (Maybe Thread) :<|>
        "recent" :> 
            Capture "tag" PostTag :>
            QueryParam "posts_amount" Int :>
            Header "Range" (Ranges '["date"] Thread) :>
            -- impossible to use headers due to servant-reflex (?) bug
            GetPartialContent '[JSON] (Paginated Thread)
    )

-- Command API
type PostsCAPI =
    "post" :> ReqBody '[JSON] PostData :> Post '[JSON] (Maybe PostID)

type PostsCQAPI = PostsCAPI :<|> PostsQAPI

type PostsAPI =
    "api" :> "v1" :> ( PostsTestAPI 
                  :<|> PostsCQAPI )

postsAPI = Proxy @PostsAPI
