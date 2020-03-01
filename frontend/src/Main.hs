-- Copyright 2019 Kyryl Vlasov
-- SPDX-License-Identifier: Apache-2.0

{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Map as Map

import Reflex.Dom

import IB2.Frontend.App (bodyElement)


main :: IO ()
main = mainWidgetWithHead headElement bodyElement

headElement :: MonadWidget t m => m ()
headElement = do
    el "title" $ text "Anonymous Imageboard"
    viewportMeta
    styleSheet "styles/main.css"

    where
        styleSheet file =
            elAttr "link" (Map.fromList
                [ ("rel", "stylesheet")
                , ("type", "text/css")
                , ("href", file) 
                ]) blank

        viewportMeta =
            elAttr "meta" (Map.fromList
                [ ("name", "viewport")
                , ("content", "width=device-width, initial-scale=1")
                ]) blank
