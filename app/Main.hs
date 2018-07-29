-- | Haskell language pragma
{-# LANGUAGE OverloadedStrings #-}

-- | Haskell module declaration
module Main where

-- | Miso framework import
import Miso
import Miso.String
import qualified Counter as C

-- | Entry point for a miso application
main :: IO ()
main = startApp C.counterApp
