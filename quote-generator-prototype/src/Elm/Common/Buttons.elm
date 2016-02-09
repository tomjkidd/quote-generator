module Common.Buttons
    ( goToProductsButton
    , logoutButton
    , removeProductFromQuoteButton
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..) 
import Html.Events exposing (..)
import Signal exposing (Address)

import I18n exposing (i18nLookup)
import Common.Util exposing (show)

import Model exposing (Page (..))
import Action exposing (Action (..))
import Model exposing (Model)

goToProductsButton : Address Action -> Model -> Html
goToProductsButton address model =
    button
        [ onClick address (NavigateToPage ProductCatalog)
        , show model.loggedIn
        ]
        [ text (i18nLookup I18n.GoToProductCatalog) ]

logoutButton : Address Action -> Model -> Html
logoutButton address model =
    button
        [ onClick address RequestLogOut
        , show model.loggedIn
        ]
        [ text (i18nLookup I18n.LogoutLabel) ]

removeProductFromQuoteButton : Address Action -> Model -> Int -> Html
removeProductFromQuoteButton address model index =
    button
        [ onClick address (RemoveProductFromQuote index)
        , show model.loggedIn
        ]
        [ i [class "fa fa-close", style [ ("padding-right", "5px") ]] []
        , text (i18nLookup I18n.RemoveProductFromQuote)
        ]
