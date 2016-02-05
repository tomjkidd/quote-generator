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
import Common.Util exposing (show, calculateBaseCost)

import Theme exposing (themeLookup)

view : Address Action -> Model -> Html
view address model =
    let products = List.map (productView address) model.productCatalog
    in
        div
            [ show (model.page == ProductCatalog) ]
            products

productView : Address Action -> Product -> Html
productView address product =
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
