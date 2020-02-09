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


replyFormEl :: MonadWidget t m => Event t PostID -> m (Event t PostID)
replyFormEl replyEvt = mdo
    contactInputEl <- inputElement def
    textInputEl <- inputElement $ def
        { _inputElementConfig_setValue = appendReplyRef }

    let replyRef = (">>" <>) . showTextData <$> replyEvt 
        appendReplyRef = Just $
            uncurry (<>) <$> attachPromptlyDyn postTextInput replyRef

        postContactInput = value contactInputEl
        postTextInput = value textInputEl

    pure $ 0 <$ never
