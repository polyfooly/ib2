-- Copyright 2020 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.UI.PageSelector where

--import Data.Text (Text)
--import qualified Data.Text as T

import Web.HttpApiData

import Reflex.Dom

--import IB2.Frontend.Types
import IB2.Frontend.Utils


pageSelectorEl :: MonadWidget t m
    => Dynamic t Int -> Dynamic t Int
    -> m (Event t Int)
pageSelectorEl total per = do
    let pageList = (\t p -> [0..(t `div` p)]) <$> total <*> per

    pages <- simpleList pageList pageButtonEl

    let page = switchPromptlyDyn $ leftmost <$> pages
    pure page

pageButtonEl :: MonadWidget t m => Dynamic t Int -> m (Event t Int)
pageButtonEl n = do
    click <- dynButton $ showTextData <$> n
    pure $ tagPromptlyDyn n click
