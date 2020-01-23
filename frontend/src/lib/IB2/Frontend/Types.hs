
module IB2.Frontend.Types where

import Data.Text (Text)

import Reflex.Dom


type GoTo t m = m (Event t Text)
