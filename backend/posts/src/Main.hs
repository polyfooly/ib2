-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Database.EventStore

import Posts
import IB2.Service.Types

main :: IO ()
main = postsService $ ServiceSettings
    { webPort = 5474
    , eventPort = 5475
    , eventCreds = credentials "admin" "changeit" }
