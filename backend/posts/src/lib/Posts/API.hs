-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Posts.API where

import Servant
--import Data.Aeson

import qualified Posts.Types as P

import IB2.Types


type CResponse = Bool

type PostsTestAPI = "postTest" :> Get '[JSON] String

type PostsQAPI = --Query API
         "post" :> Capture "id" Int :> Get '[JSON] (Maybe P.Post)

type PostsCAPI = EmptyAPI' --Control API
        --"post" :> Capture "post" P.Post :> Post '[JSON] CResponse

type PostsAPI = PostsTestAPI :<|> PostsQAPI  :<|> PostsCAPI

postsAPI :: Proxy PostsAPI
postsAPI = Proxy
