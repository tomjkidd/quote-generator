module Login
    (view
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Address)

import Model exposing (..)
import Action exposing (Action(..))
import I18n exposing (I18nMessage(..))
import Theme exposing (themeLookup)

view : Address Action -> Model -> Html
view address model =
    let i18nLookup = model.i18nLookup
    in
        div
            [ class "login-view", hidden model.loggedIn, style [ ("max-width", "500px"),  ("margin", "0 auto")] ]
            [ div
                [ class "login-background"
                , style
                    [ ("backgroundColor", themeLookup Theme.LoginViewColor)
                    , ("color", themeLookup Theme.LoginViewTextColor)
                    , ("display", "flex")
                    , ("flex-direction", "row")
                    , ("flex-wrap", "wrap")
                    ]
                ]
                [ img
                    [ src "images/login-logo.png", width 100, height 100
                    , style [("padding", "5px")]
                    ]
                    []
                , div
                    [ style [ ("align-self", "center"), ("justify-content", "center"), ("padding", "0 0 0 15px") ]]
                    [ div [ class "login-title h2"] [ text (i18nLookup I18n.LoginTitle) ]
                    , div [ class "login-subtitle h3"] [ text (i18nLookup I18n.LoginSubtitle) ]
                    ]
                ]
            , googleSignInView address model
            ]

-- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
googleSignInView : Address Action -> Model -> Html
googleSignInView address model =
    div
        [ class "g-signin2"
        , style [ ("width", "120"), ("margin", "0 auto"), ("padding", "10px 0 0 0") ]
        , attribute "data-onsuccess" "onSignIn"
        , attribute "data-theme" "dark"
        ] []
