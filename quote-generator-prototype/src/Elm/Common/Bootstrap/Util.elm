module Common.Bootstrap.Util
    ( panelView
    , tableView)
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Address)

import Action exposing (Action (..))

{-| Based on minimum needed to create a Bootstrap Panel -}
panelView : Address Action -> Html -> Html -> Html
panelView address heading body =
    let a = 1
    in
        div
            [ class "panel panel-default"
            , style [ ("margin-bottom", "0px") ]
            ]
            [ div
                [ class "panel-heading" ]
                [ heading ]
            , div
                [ class "panel-body"]
                [ body ]
            ]

{-| Based on minimum needed to create a Bootstrap Table -}
tableView : Address Action -> Html -> List Html -> Html
tableView address headerRow bodyRows =
    table
        [ class "table table-condensed table-striped" ]
        [ thead [] [ headerRow ]
        , tbody [] bodyRows
        ]
