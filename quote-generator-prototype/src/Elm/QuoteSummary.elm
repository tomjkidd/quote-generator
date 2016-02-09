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
        totalCostView =
            div
                [ class "input-group"
                , style [ ("padding", "5px 0") ]
                ]
                [ span
                    [ class "input-group-addon" ]
                    [ text (i18nLookup I18n.QuoteTotalCost)]
                , div
                    [ class "form-control quote-total-cost"
                    , style [ ("display", "inline-block")
                           , ("font-weight", "600")
                           ]
                    ]
                    [ text (formatCurrency totalCost) ]
                ]
    in
        div
            [ class "quote-summary-view"
            , show (model.page == QuoteSummary)
            ]

            [ div
                [ hidden quoteHasProducts]
                [ div [] [ text (i18nLookup I18n.NoProductsInQuote) ] ]
            , div [ class "h2", show quoteHasProducts ] [ text (i18nLookup I18n.QuoteSummary) ]
            , div [ class "products", show quoteHasProducts ] productViews
            , div
                [ class "row"
                , style [ ("border-top", "1px solid #eee") ]
                , show quoteHasProducts
                ]
                [ div
                    [ class "col-md-12"
                    , style [ ("text-align", "right") ]
                    ]
                    [ totalCostView ]
                ]
            , goToProductsButton address model
            , button [ onClick address (HttpRequestSubmitQuote model.quote), show (model.loggedIn && model.quote.products /= []) ] [ text (i18nLookup I18n.SubmitQuote) ]
            ]

productViewLegacy : Address Action -> Model -> Int -> Product -> Html
productViewLegacy address model index product =
    let totalCost = calculateTotalCost product
    in
        div
            []
            [ div [] [ text product.title ]
            , div [] [ text (formatCurrency totalCost) ]
            , removeProductFromQuoteButton address model index
            ]

productView : Address Action -> Model -> Int -> Product -> Html
productView address model index product =
    let totalCost = calculateTotalCost product
        linkToSample =
            case product.linkToSample of
                Nothing -> div [] []
                Just l -> a [] [ text (i18nLookup I18n.LinkToSample) ]

        totalCostLabel =
            div
                [ class "h5"
                , style [ ("display", "inline-block")
                        ]
                ]
                [ text (i18nLookup I18n.BaseCost) ]

        totalCostValue =
             div
                [ class "form-control"
                , style [ ("display", "inline-block")
                        , ("font-weight", "600")
                        ]
                ]
                [ text (formatCurrency totalCost) ]

        removeProductButton =
            div
                [ onClick address (RemoveProductFromQuote index)
                , show model.loggedIn
                , class "input-group-addon"
                ]
                [ i [class "fa fa-close"
                --, style [ ("padding-right", "5px") ]
                ] []
                --, text (i18nLookup I18n.RemoveProductFromQuote)
                ]

        totalCostInputGroup =
            div
                [ class "input-group" ]
                [ span
                    [ class "input-group-addon" ]
                    [ text (i18nLookup I18n.Cost)]
                , totalCostValue
                , removeProductButton
                ]

    in
        div [ class "quote-product"
            --, onClick address (SelectProduct product)
            ]
            [ div
                [ class "row" ]
                [ div
                    [ class "h4 col-sm-12" ]
                    [ text product.title ]
                ]
            , div
                [ class "row" ]
                [ div
                    [ class "col-sm-12" ]
                    [ text product.description ]
                ]
            , div
                [ class "row"]
                [ div
                    [ class "col-md-9" ]
                    [ ]
                , div
                    [ class "col-md-3"
                    , style
                        [ ("text-align", "right")
                        , ("padding-bottom", "5px")
                        ]
                    ]
                    [ totalCostInputGroup ]
                ]
            ]
