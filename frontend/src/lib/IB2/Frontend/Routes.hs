-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module IB2.Frontend.Routes where

import IB2.Frontend.Types

rootRoute, mainRoute :: Route
rootRoute = ""
mainRoute = ""

boardRoute, threadRoute :: Route -> Route
boardRoute = (<>) "board/"
threadRoute = (<>) "thread/"
