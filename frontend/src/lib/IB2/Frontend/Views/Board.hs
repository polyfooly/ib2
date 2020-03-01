-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
--{-# LANGUAGE ScopedTypeVariables #-}
--{-# LANGUAGE PartialTypeSignatures #-}
--{-# LANGUAGE LambdaCase #-}

module IB2.Frontend.Views.Board where

import Data.Text (Text)
--import qualified Data.Text as T

import Web.HttpApiData

import Reflex.Dom

import IB2.Common.Types

import IB2.Frontend.Types
import IB2.Frontend.UI.Thread
import IB2.Frontend.UI.BoardHeader
import IB2.Frontend.UI.PageSelector
import IB2.Frontend.API.Client
import IB2.Frontend.Routes
import IB2.Frontend.Utils


boardView :: MonadWidget t m => Text -> GoTo t m
boardView boardTag = mdo
    pb <- getPostBuild

    let tag' = constDyn boardTag
        previewPostsAmount = constDyn $ Just 3
        per = constDyn 10
    
    goToHeader <- boardHeaderEl tag'
    page <- holdDyn 0 pageSelected

    let loadThreads = leftmost [ pb, () <$ pageSelected ]
    (totalCount, threads') <- recentThreadsPaginated tag' per page previewPostsAmount loadThreads

    (goToThread, pageSelected) <- splitSwitchDyn <$> maybeWidgetHoldDyn totalCount
        boardFallback
        (\n -> boardView' threads' (constDyn n) per)
    
    let goTo = leftmost [ goToHeader, goToThread ]
    pure goTo

boardView' :: MonadWidget t m => Dynamic t [Thread]
    -> Dynamic t Int -> Dynamic t Int
    -> m (Event t Route, Event t Int)
boardView' threads' total per = do
    page <- pageSelectorEl total per
    replyEvts <- simpleList threads' $ threadEl ThreadPreview

    let threadReplies = switchPromptlyDyn $ leftmost <$> replyEvts
        goTo = threadRoute . showTextData <$> threadReplies

    pure (goTo, page)

boardFallback :: MonadWidget t m => m (Event t Route, Event t Int)
boardFallback = do
    pure (never, never)
