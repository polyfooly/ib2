-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
--{-# LANGUAGE ScopedTypeVariables #-}

module IB2.Frontend.UI.Thread where

import Reflex.Dom

import IB2.Common.Types

import IB2.Frontend.UI.Post


threadEl :: MonadWidget t m => Dynamic t Thread -> m (Event t Int)
threadEl thread = 
    el "div" $ do
        opReply <- postEl $ opPost <$> thread
        
        bodyReplies <- simpleList 
            (threadPosts <$> thread)
            postEl

        let replies = (opReply :) <$> bodyReplies
            reply = switchPromptlyDyn $ leftmost <$> replies

        return reply
