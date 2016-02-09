module QuoteSummary
    (view)
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Model exposing (Model, Product, Page(..))
import Action exposing (Action(..))

import I18n exposing (i18nLookup)
import Common.Util exposing (show
    , formatCurrency
    , calculateTotalCost, calculateQuoteTotalCost)
import Common.Buttons exposing (goToProductsButton
    ,removeProductFromQuoteButton)

view : Address Action -> Model -> Html
view address model =
    let quoteHasProducts = model.quote.products /= []
        totalCost = calculateQuoteTotalCost model.quote
        productViews = List.indexedMap (productView address model) model.quote.products
    in
        div
            [ class "quote-summary-view"
            , show (model.page == QuoteSummary)
            ]

            [ div
                [ hidden quoteHasProducts]
                [ div [] [ text (i18nLookup I18n.NoProductsInQuote) ] ]
            , div [ class "products", show quoteHasProducts ] productViews
            , div [ class "quote-total-cost", show quoteHasProducts ] [ text (formatCurrency totalCost) ]
            , goToProductsButton address model
            , button [ onClick address (HttpRequestSubmitQuote model.quote), show (model.loggedIn && model.quote.products /= []) ] [ text (i18nLookup I18n.SubmitQuote) ]
            ]

productView : Address Action -> Model -> Int -> Product -> Html
productView address model index product =
    let totalCost = calculateTotalCost product
    in
        div
            []
            [ div [] [ text product.title ]
            , div [] [ text (formatCurrency totalCost) ]
            , removeProductFromQuoteButton address model index
            ]
