-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE ViewPatterns #-}

module IB2.Frontend.App where

import Data.Functor

import Web.HttpApiData

import Reflex.Dom

import IB2.Frontend.Views.Main
import IB2.Frontend.Views.Board
import IB2.Frontend.Views.Thread
--import IB2.Frontend.Routes
import IB2.Frontend.Router


bodyElement :: (MonadWidget t m) => m ()
bodyElement = mdo
    --pb <- getPostBuild

    currRoute <- routeApp . switchPromptlyDyn =<< holdDyn never views
    let fallbackView = mainView
    views <- dyn $ currRoute <&> \case
        ["board", tag']                       -> boardView tag'
        ["thread", readTextData -> Right id'] -> threadView id'
        [""]                                  -> mainView
        _                                     -> fallbackView
 
    blank
