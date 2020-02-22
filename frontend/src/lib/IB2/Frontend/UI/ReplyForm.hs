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
replyFormEl parent tags replyEvt =
    el "div" $ do
        let defInpConf = def
        contactInputEl <- elClass "div" "field" $ do
            elClass "label" "label" $ text "Contact:"
            elClass "div" "control" $ inputElement defInpConf
                { _inputElementConfig_elementConfig = (_inputElementConfig_elementConfig defInpConf)
                    { _elementConfig_initialAttributes = "class" =: "input" } }
    
        rec let replyRef = (">>" <>) . showTextData <$> replyEvt
                appendReplyRef = Just $
                    uncurry (<>) <$> attachPromptlyDyn postTextInput replyRef
                postTextInput = value textInputEl

            textInputEl <- elClass "div" "field" $ do
                elClass "label" "label" $ text "Post text:"
                elClass "div" "control" $ inputElement $ defInpConf
                    { _inputElementConfig_setValue = appendReplyRef 
                    , _inputElementConfig_elementConfig = def
                        { _elementConfig_initialAttributes = "class" =: "input" } }
            
        replyTrigger <- elClass "div" "field" $
            elClass "div" "control" $ do
                (evt, _) <- elClass' "button" "button is-link" $ text "Submit"
                pure $ domEvent Click evt

        let postContactInput = value contactInputEl
            replyPostData = PostData []
                <$> postTextInput
                <*> parent
                <*> tags

        replyId <- postPost replyPostData replyTrigger
        pure $ fmapMaybe id replyId
