-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE LambdaCase #-}
--{-# LANGUAGE ScopedTypeVariables #-}

module IB2.Frontend.App where

--import Data.Map as Map
import Data.Time
import Data.Functor

import Reflex
import Reflex.Dom
import Reflex.Dom.Contrib.Router

import IB2.Common.Types

import IB2.Frontend.UI.Thread
import IB2.Frontend.Views.Main
import IB2.Frontend.Views.Board
import IB2.Frontend.Views.Thread


bodyElement :: MonadWidget t m => m ()
bodyElement = do
    rec route <- partialPathRoute "" . switchPromptlyDyn =<< holdDyn never views
        views <- dyn $ route <&> \case
            ["boards", id'] -> boardView id'
            ["thread", id'] -> threadView id'
            _               -> mainView

    --replyEvt <- defaultThread
    blank

defaultThread :: MonadWidget t m => m (Event t Int)
defaultThread =
    threadEl $ constDyn defaultThreadData

defaultThreadData = Thread
    { opPost = defaultPostData
    , threadPosts =
        [ defaultPostData { postIndex = 2 }
        , defaultPostData { postIndex = 3 }
        , defaultPostData { postIndex = 4 }
        ]
    }

defaultDate = UTCTime (fromGregorian 0 0 0) 0
defaultPostData = Post (HashedPost (PostData defaultDate [] "" 0 []) 1) 1
