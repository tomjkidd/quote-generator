module Common.Debug
    (debugPanel
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Action exposing (Action (..))
import Model exposing (Model)
import Common.Util exposing (show)

-- TODO: Create a simple wrapper for making these buttons.

requestAuthButton : Address Action -> Model -> Html
requestAuthButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address RequestAuth, show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Auth"
            ]

requestErrorButton : Address Action -> Model -> Html
requestErrorButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address (Error "This is an Error test"), show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Error"
            ]

requestNotifyButton : Address Action -> Model -> Html
requestNotifyButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address (Notify "This is a Notify test"), show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Notify"
            ]

debugPanel : Address Action -> Model -> Bool -> Html
debugPanel address model showDebugPanel =
    if showDebugPanel
        then
            div
                []
                [ div [] [ text (toString model.page) ]
                , div [] [ text (toString model.quote) ]
                , div [] [ text (toString model.confirmation) ]
                , requestAuthButton address model
                , requestNotifyButton address model
                , requestErrorButton address model
                ]
        else div [] []
