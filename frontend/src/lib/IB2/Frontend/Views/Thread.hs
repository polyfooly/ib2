-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE LambdaCase #-}

module IB2.Frontend.Views.Thread where

--import qualified Data.Text as T
import Data.Text (Text)

import Web.HttpApiData

import Reflex.Dom

import IB2.Common.Types

import IB2.Frontend.API.Client
import IB2.Frontend.Types
import IB2.Frontend.UI.BoardHeader
import IB2.Frontend.UI.Thread
import IB2.Frontend.Routes


threadView :: MonadWidget t m => PostID -> GoTo t m
threadView id' = do
    pb <- getPostBuild
    let threadId = constDyn id'

    goToHeader <- boardHeaderEl ((<>) "Thread №" . showTextData <$> threadId)
    thread <- getThreadById threadId pb

    view <- dyn $ ffor thread $ \case
        Just th -> threadView' (constDyn th)
        Nothing -> wrongIdFallback

    goHome <- switchHold never view

    let goTo = leftmost [ goHome, goToHeader ]
    pure goTo

threadView' :: MonadWidget t m => Dynamic t Thread -> GoTo t m
threadView' thread = do
    reply <- threadEl ThreadFull thread
    pure never

wrongIdFallback :: MonadWidget t m => GoTo t m
wrongIdFallback = do
    goHome <- button "Return Home"
    pure $ mainRoute <$ goHome
