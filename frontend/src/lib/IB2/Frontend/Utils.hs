-- Copyright 2020 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE LambdaCase #-}
--{-# LANGUAGE PartialTypeSignatures #-}

module IB2.Frontend.Utils where

--import Control.Monad

import Data.Text (Text)

import Reflex.Dom


dynButton :: MonadWidget t m => Dynamic t Text -> m (Event t ())
dynButton txt = do
    butText <- sample $ current txt
    button butText

splitSwitchDyn :: (Reflex t)
    => Dynamic t (Event t a, Event t b) 
    -> (Event t a, Event t b)
splitSwitchDyn = (\(g, p) -> (switchDyn g, switchDyn p)) . splitDynPure

maybeWidgetHoldDyn :: (MonadWidget t m)
    => Dynamic t (Maybe a)
    -> m b -> (a -> m b) -> m (Dynamic t b)
maybeWidgetHoldDyn maybeData def' widget = do
    let widgetEvt = updated $ ffor maybeData $ \case
            Just d -> widget d
            Nothing -> def'

    resDyn <- widgetHold def' widgetEvt
    pure resDyn
