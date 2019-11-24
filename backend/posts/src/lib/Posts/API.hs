-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Posts.API where

import Servant
--import Data.Aeson

type PostsAPI = "test" :> Get '[JSON] String 

postsAPI :: Proxy PostsAPI
postsAPI = Proxy

