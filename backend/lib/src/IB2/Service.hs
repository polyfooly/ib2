-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

module IB2.Service 
    ( module IB2.Service
    , module IB2.Service.Reducer
    ) where

import Control.Concurrent.STM
import Control.Monad.IO.Class

import Servant

import IB2.Service.Reducer
