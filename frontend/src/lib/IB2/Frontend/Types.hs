
module IB2.Frontend.Types where

import Data.Text (Text)

import Reflex.Dom


type Route = Text

type GoTo t m = m (Event t Route)
  