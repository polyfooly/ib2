{-# LANGUAGE OverloadedStrings #-}

module UI where

import Reflex.Dom

appUI :: IO ()
appUI = mainWidget $ text "is there anybody out there?"
