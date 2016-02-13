module ProductCatalog
    ( view
    , productView
    )
    where

import Signal exposing (Address)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Action exposing (Action (..))
import Model exposing (Model, Page (ProductCatalog), Product)
import Common.Util exposing (show, formatCurrency, calculateBaseCost)
import I18n exposing (I18nMessage(..))

import Theme exposing (themeLookup)

view : Address Action -> Model -> Html
view address model =
    let products = List.map (productView model.i18nLookup True address) model.productCatalog
    in
        div
            [ show (model.page == ProductCatalog)
            , class "product-catalog"
            ]
            products

{- TODO: Remove once happy with productView -}
productViewLegacy : Address Action -> Product -> Html
productViewLegacy address product =
    let baseCost = calculateBaseCost product
    in
        div
            [ onClick address (SelectProduct product)
            , style
                [ ("backgroundColor", (themeLookup Theme.ProductViewColor))
                , ("margin", "5px 0")
                ]
            ]

            [ div [] [text product.title]
            , div [] [text product.description]
            , div [] [text (toString baseCost)]
            ]

productView : (I18nMessage -> String) -> Bool -> Address Action -> Product -> Html
productView i18nLookup showBaseCost address product =
    let baseCost = calculateBaseCost product
        linkToSample =
            case product.linkToSample of
                Nothing -> div [] []
                Just l -> a [] [ text (i18nLookup I18n.LinkToSample) ]

        baseCostLabel =
            div
                [ class "h5"
                , style [ ("display", "inline-block")
                        ]
                ]
                [ text (i18nLookup I18n.BaseCost) ]

        baseCostValue =
             div
                [ class "form-control"
                , style [ ("display", "inline-block")
                        , ("font-weight", "600")
                        ]
                ]
                [ text (formatCurrency baseCost) ]

        baseCostInputGroup =
            if showBaseCost
            then
                div
                    [ class "input-group" ]
                    [ span
                        [ class "input-group-addon" ]
                        [ text (i18nLookup I18n.BaseCost)]
                    , baseCostValue
                    ]
            else div [] []

    in
        div [ class "product"
            , onClick address (SelectProduct product) ]
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
                    [ baseCostInputGroup ]
                ]
            ]
