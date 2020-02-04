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
bodyElement = do
    --pb <- getPostBuild

    rec currRoute <- routeApp . switchPromptlyDyn =<< holdDyn never views
        views <- dyn $ currRoute <&> \case
            ["board", tag']                       -> boardView tag'
            ["thread", readTextData -> Right id'] -> threadView id'
            _                                     -> mainView
    blank

{-defaultThread :: MonadWidget t m => m (Event t Int)
defaultThread =
    threadEl ThreadFull $ constDyn defaultThreadData

defaultThreadData = Thread
    { opPost = defaultPostData
    , threadPosts =
        [ defaultPostData { postIndex = 2 }
        , defaultPostData { postIndex = 3 }
        , defaultPostData { postIndex = 4 }
        ]
    }

defaultDate = UTCTime (fromGregorian 0 0 0) 0
defaultPostData = Post (HashedPost (PostData defaultDate [] "" 0 []) 1) 1-}
