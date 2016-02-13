module Home
    (view
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Address)

import Action exposing (Action (..))
import Model exposing (Model, Page (Home))
import Common.Buttons exposing (goToProductsButton)
import Common.Util exposing (show)

view : Address Action -> Model -> Html
view address model =
    let h = model.homeDetails
        i18nLookup = model.i18nLookup
    in
        div
            [ class "home-view"
            , show (model.page == Home)
            , style [("max-width", "500px"),("margin", "0 auto")]
            ]
            [ div [ class "h3" ] [ text (i18nLookup h.title) ]
            , div [ class "h4" ] [ text (i18nLookup h.summary) ]
            , div [ style [("white-space", "pre-wrap")] ] [ text (i18nLookup h.description) ]
            , goToProductsButton i18nLookup address model
            ]
