-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module UI where

import Reflex.Dom

appUI :: IO ()
appUI = mainWidget $ text "is there anybody out there?"
