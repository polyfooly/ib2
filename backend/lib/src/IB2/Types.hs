{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module IB2.Types where

import Servant

type EmptyAPI' = "empty" :> Get '[JSON] String 
emptyServer' :: Monad m => m String
emptyServer' = return "empty"