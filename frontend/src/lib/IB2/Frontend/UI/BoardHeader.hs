-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.UI.BoardHeader where

import Data.Text (Text)
--import qualified Data.Text as T

import Reflex.Dom

import IB2.Frontend.Types


navBar :: MonadWidget t m => GoTo t m
navBar = do
    let goTo = undefined
    return goTo 

boardHeaderEl :: MonadWidget t m => Text -> GoTo t m
boardHeaderEl title = do
    goTo <- navBar

    return goTo
