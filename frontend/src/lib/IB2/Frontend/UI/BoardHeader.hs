-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.UI.BoardHeader where

import Data.Text (Text)
--import qualified Data.Text as T

import Reflex.Dom

import IB2.Common.Types

import IB2.Frontend.Types
import IB2.Frontend.Routes
import IB2.Frontend.Utils


boardHeaderEl :: MonadWidget t m => Dynamic t Text -> GoTo t m
boardHeaderEl title = do
    goTo <- navBar
    dynText title

    pure goTo

navBar :: MonadWidget t m => GoTo t m
navBar = do
    let boards = constDyn [ "b", "crypt" ]
    goTos <- simpleList boards navButton
        
    pure $ switchPromptlyDyn $ leftmost <$> goTos

navButton :: MonadWidget t m 
    => Dynamic t PostTag
    -> GoTo t m
navButton tag' = do
    click <- dynButton tag'
    pure $ tagPromptlyDyn (boardRoute <$> tag') click
