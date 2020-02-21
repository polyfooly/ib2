-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
--{-# LANGUAGE FlexibleContexts #-}
--{-# LANGUAGE PartialTypeSignatures #-}

module IB2.Frontend.UI.ReplyForm where

import Web.HttpApiData

import Reflex.Dom

import IB2.Common.Types

import IB2.Frontend.API.Client


replyFormEl :: (MonadWidget t m)
    => Dynamic t PostID
    -> Dynamic t [PostTag]
    -> Event t PostID
    -> m (Event t PostID)
replyFormEl parent tags replyEvt = mdo
    contactInputEl <- inputElement def
    textInputEl <- inputElement $ def
        { _inputElementConfig_setValue = appendReplyRef }
    replyTrigger <- button "Submit"

    let replyRef = (">>" <>) . showTextData <$> replyEvt 
        appendReplyRef = Just $
            uncurry (<>) <$> attachPromptlyDyn postTextInput replyRef

        postContactInput = value contactInputEl
        postTextInput = value textInputEl

        postData = PostData []
            <$> postTextInput
            <*> parent
            <*> tags

    replyId <- postPost postData replyTrigger
    let replyId_ = fmapMaybe id replyId
    pure replyId_
