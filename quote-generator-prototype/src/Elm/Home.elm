module Home
    (view
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Address)

import I18n exposing (i18nLookup)
import Action exposing (Action (..))
import Model exposing (Model, Page (Home))
import Common.Buttons exposing (goToProductsButton)
import Common.Util exposing (show)

view : Address Action -> Model -> Html
view address model =
    div
        [ class "home-view", show (model.page == Home) ]
        [ div [] [ text (i18nLookup I18n.HomeTitle) ]
        , div [] [ text (i18nLookup I18n.HomeSummary) ]
        , div [] [ text (i18nLookup I18n.HomeDescription) ]
        , goToProductsButton address model
        ]
