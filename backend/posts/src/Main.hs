-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Posts

main :: IO ()
main = Posts.service 5474
