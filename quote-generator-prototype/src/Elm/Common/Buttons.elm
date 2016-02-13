module Common.Buttons
    ( goToProductsButton
    , logoutButton
    , removeProductFromQuoteButton
    , helpButton
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import I18n exposing (I18nMessage(..))
import Common.Util exposing (show)

import Model exposing (Page (..))
import Action exposing (Action (..))
import Model exposing (Model)

goToProductsButton : (I18nMessage -> String) -> Address Action -> Model -> Html
goToProductsButton i18nLookup address model =
    button
        [ onClick address (NavigateToPage ProductCatalog)
        , show model.loggedIn
        ]
        [ text (i18nLookup I18n.GoToProductCatalog) ]

logoutButton : (I18nMessage -> String) -> Address Action -> Model -> Html
logoutButton i18nLookup address model =
    button
        [ onClick address RequestLogOut
        , show model.loggedIn
        ]
        [ text (i18nLookup I18n.LogoutLabel) ]

removeProductFromQuoteButton : (I18nMessage -> String) -> Address Action -> Model -> Int -> Html
removeProductFromQuoteButton i18nLookup address model index =
    button
        [ onClick address (Action.RemoveProductFromQuote index)
        , show model.loggedIn
        ]
        [ i [class "fa fa-close", style [ ("padding-right", "5px") ]] []
        , text (i18nLookup I18n.RemoveProductFromQuote)
        ]

helpButton : (I18nMessage -> String) -> Address Action -> Model -> Html
helpButton i18nLookup address model =
    button
        [ onClick address (NavigateToPage Home)
        , show model.loggedIn
        , class ""
        ]
        [ i [class "fa fa-question-circle", style [ ("padding-right", "5px") ]] []
        , text (i18nLookup I18n.Help)
        ]
