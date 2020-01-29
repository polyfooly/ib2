-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
--{-# LANGUAGE ScopedTypeVariables #-}

module IB2.Frontend.UI.Post where

--import Reflex
import Reflex.Dom

import IB2.Common.Types


postEl :: MonadWidget t m => Dynamic t Post -> m (Event t Int)
postEl post = do
    clk <- el "div" $ do
        clk <- el "div" $ do -- title
            el "span" $
                display $ postDate . postData . hashedPost <$> post
            el "span" $
                display $ postIndex <$> post
            
            button "Reply"

        el "div" $ do -- body
            el "div" $
                dynText $ postText . postData . hashedPost <$> post

        return clk
    
    -- reply with id
    return $ tagPromptlyDyn (postIndex <$> post) clk
