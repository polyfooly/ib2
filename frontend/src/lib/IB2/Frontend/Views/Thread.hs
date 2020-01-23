-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.Views.Thread where

import qualified Data.Text as T

import Reflex.Dom


threadView :: MonadWidget t m => T.Text -> m (Event t T.Text)
threadView id' = undefined
    