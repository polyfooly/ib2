-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE AllowAmbiguousTypes #-}

module IB2.Frontend.API.Client where

import Data.Proxy

import Reflex.Dom hiding (Client)
import Servant.Reflex 
    
import IB2.Common.API
import IB2.Common.Types


apiClient :: forall t m. MonadWidget t m => Client t m PostsAPI ()
apiClient = client postsAPI 
    (Proxy @m) (Proxy @()) (constDyn baseURL)
    where baseURL = BasePath "/"
