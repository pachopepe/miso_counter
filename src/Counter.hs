-- | Haskell language pragma
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

-- | Haskell module declaration
module Counter where

-- | Miso framework import
import Miso
import Miso.String

-- | Type synonym for an application model
type Model = Int

-- | Sum type for application events
data Action
  = AddOne
  | SubtractOne
  | NoOp
  | SayHelloWorld
  deriving (Show, Eq)

counterApp :: App Model Action
counterApp = App {..}
  where
    initialAction = SayHelloWorld     -- initial action to be executed on application load
    model  = initialModel             -- initial model
    update = updateModel              -- update function
    view   = viewModel                -- view function
    events = defaultEvents            -- default delegated events
    subs   = []                       -- empty subscription list
    mountPoint = Nothing              -- mount point for application (Nothing defaults to 'body')

initialModel :: Model
initialModel = 0

-- | Updates model, optionally introduces side effects
updateModel :: Action -> Model -> Effect Action Model
updateModel AddOne m = noEff (m + 1)
updateModel SubtractOne m = noEff (m - 1)
updateModel NoOp m = noEff m
updateModel SayHelloWorld m = m <# do
  putStrLn "Hello World" >> pure NoOp

-- | Constructs a virtual DOM from a model
viewModel :: Model -> View Action
viewModel x = div_ [] [
   button_ [ onClick AddOne ] [ text "+" ]
 , text (ms x)
 , button_ [ onClick SubtractOne ] [ text "-" ]
 ]

