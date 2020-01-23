-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecursiveDo #-}

module IB2.Frontend.Views.Main where

import Data.Text (Text)

import Reflex.Dom

import IB2.Frontend.Types
import IB2.Frontend.Views.Board


mainView :: MonadWidget t m => GoTo t m
mainView = boardView "b"