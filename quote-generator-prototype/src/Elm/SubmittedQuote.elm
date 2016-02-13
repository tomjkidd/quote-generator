module SubmittedQuote
    (view
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)

import Signal exposing (Address)

import Model exposing (Model, Page(..))
import Action exposing (Action(..))

import Common.Util exposing (show)
import Common.Buttons exposing (goToProductsButton, logoutButton)
import I18n exposing (I18nMessage(..))
import Uuid

view : Address Action -> Model -> Html
view address model =
    let
        i18nLookup = model.i18nLookup
        confNumberList =
            ul
                [ class "list-group" ]
                [ li
                    [ class "h4 list-group-item" ]
                    [ text (i18nLookup I18n.ConfirmationNumber) ]
                , li
                    [ class "list-group-item" ]
                    [ text (Uuid.toString model.confirmation) ]

                ]
    in
        div
            [ class "submitted-quote-view"
            , show (model.page == SubmittedQuote)
            ]

            [ div [ class "h3" ] [ text (i18nLookup I18n.QuoteSubmittedTitle) ]
            , div [] [ text (i18nLookup I18n.QuoteSubmittedInfo) ]
            , confNumberList
            , goToProductsButton i18nLookup address model
            , logoutButton i18nLookup address model
            ]
