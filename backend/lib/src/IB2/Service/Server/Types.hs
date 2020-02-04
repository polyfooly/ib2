-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module IB2.Service.Server.Types where

import Data.Aeson
import GHC.Generics

import Servant

type EmptyAPI' = "empty" :> Get '[JSON] String

-- total length + page
data Paginated a = Paginated
    { resourcePage :: [a]
    , resourceTotalCount :: Int }
    deriving (Generic, ToJSON, FromJSON)
