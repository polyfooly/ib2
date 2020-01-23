-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.Views.Board where

import Data.Text (Text)

import Reflex.Dom

import IB2.Frontend.Types
import IB2.Frontend.UI.Thread
import IB2.Frontend.UI.BoardHeader


boardView :: MonadWidget t m => Text -> GoTo t m
boardView id' = do
    goToHeader <- boardHeaderEl id'

    let threads = constDyn []
    replyEvts <- simpleList threads threadEl

    let goToThreads = switchPromptlyDyn $ leftmost <$> replyEvts
        goToThread = ((<>) "thread/" . read . show) <$> goToThreads
        goTo = leftmost [ goToHeader, goToThread ]

    return goTo

