module Common.Bootstrap.Util
    ( panelView
    , tableView)
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Model exposing (Page (..))
import Action exposing (Action (..))
import Model exposing (Model)

{-| Based on minimum needed to create a Bootstrap Panel -}
panelView : Address Action -> Html -> Html -> Html
panelView address heading body =
    let a = 1
    in
        div
            [ class "panel panel-default" ]
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
        [ class "table table-striped" ]
        [ thead [] [ headerRow ]
        , tbody [] bodyRows
        ]
