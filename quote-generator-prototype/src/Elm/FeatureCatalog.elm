module FeatureCatalog
    (view
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import String

import Action exposing (Action (..))
import Model exposing (Model, Page (..), Product, Feature)

import I18n exposing (i18nLookup)
import Common.Util exposing (show, formatCurrency
    , calculateBaseCost, calculateTotalCost)
import Common.Bootstrap.Util exposing (panelView, tableView)
import ProductCatalog

view : Address Action -> Model -> Html
view address model =
    let product = model.selectedProduct
    in
        case product of
            Nothing -> div [ show (model.page == ProductFeatures) ] [ text "Not selected product..."]
            Just p ->
                div
                    [ show (model.page == ProductFeatures) ]
                    [ productDetailView address p ]

productDetailView : Address Action -> Product -> Html
productDetailView address product =
    let
        baseCost = calculateBaseCost product
        totalCost = calculateTotalCost product
        baseFeatures = baseFeaturesView address product
        additionalFeatures = additionalFeaturesView address product
    in
        div [] <|
            [ ProductCatalog.productView address product ] ++
            [ baseFeatures
            , div [ class "text-right"] [ text (formatCurrency baseCost)]
            , additionalFeatures
            , div [ class "text-right"] [ text (formatCurrency totalCost) ]
            , div
                [ class "submit-quote text-right"]
                [ button [ onClick address (AddProductToQuote product) ] [ text (i18nLookup I18n.AddProductToQuote) ]
                ]
            ]

baseFeaturesHeaderView : Address Action -> Product -> Html
baseFeaturesHeaderView address product =
    let headerRow =
        tr
            []
            [ th [] [ text (i18nLookup I18n.Feature) ]
            , th [] [ text (i18nLookup I18n.Description) ]
            , th [] [ text (i18nLookup I18n.Type) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Cost) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Quantity) ]
            ]
    in
        headerRow

baseFeatureRowView : Address Action -> Feature -> Html
baseFeatureRowView address feature =
    tr
        []
        [ td [] [ text feature.title ]
        , td [] [ text feature.description ]
        , td [] [ text (Maybe.withDefault "" feature.featureType) ]
        , td [ class "text-right" ] [ text (formatCurrency feature.cost) ]
        , td [ class "text-center" ] [ text (toString feature.quantity) ]
        ]

baseFeaturesBodyView : Address Action -> Product -> List Html
baseFeaturesBodyView address product =
    let baseFeatures = (List.filter (\p -> p.baseFeature) product.features)
        bodyRows = (List.map (\f -> baseFeatureRowView address f) baseFeatures)
    in bodyRows


baseFeaturesView : Address Action -> Product -> Html
baseFeaturesView address product =
    let heading = text (i18nLookup I18n.BaseFeaturesTitle)

        headerRow = baseFeaturesHeaderView address product
        bodyRows = baseFeaturesBodyView address product

        body = tableView address headerRow bodyRows
    in
        panelView address heading body

additionalFeaturesHeaderView : Address Action -> Product -> Html
additionalFeaturesHeaderView address product =
    let headerRow =
        tr
            []
            [ th [] [ text (i18nLookup I18n.Feature) ]
            , th [] [ text (i18nLookup I18n.Description) ]
            , th [] [ text (i18nLookup I18n.Type) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Cost) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Quantity) ]
            ]
    in
        headerRow

additionalFeatureRowView : Address Action -> Feature -> Html
additionalFeatureRowView address feature =
    tr
        []
        [ td [] [ text feature.title ]
        , td [] [ text feature.description ]
        , td [] [ text (Maybe.withDefault "" feature.featureType) ]
        , td [ class "text-right" ] [ text (formatCurrency feature.cost) ]
        , td
            [ class "text-center" ]
            [ input
                [ value (toString feature.quantity)

                , type' "number"
                , on "input" targetValue
                    (\qty ->
                        case feature.id of
                            Nothing -> Signal.message address NoOp
                            Just id ->
                                let parsedQty = (String.toInt qty)
                                    action =
                                        case parsedQty of
                                            Err _ -> NoOp
                                            Ok n -> (UpdateQuantity id n)
                                in
                                    Signal.message address action)
                , style [ ("width", "50px") ]
                , class "text-right"
                ]
                []
            ]
        ]

additionalFeaturesBodyView : Address Action -> Product -> List Html
additionalFeaturesBodyView address product =
    let additionalFeatures = (List.filter (\p -> not p.baseFeature) product.features)
        bodyRows = (List.map (\f -> additionalFeatureRowView address f) additionalFeatures)
    in bodyRows

additionalFeaturesView : Address Action -> Product -> Html
additionalFeaturesView address product =
    let heading = text (i18nLookup I18n.AdditionalFeaturesTitle)
        headerRow = additionalFeaturesHeaderView address product
        bodyRows = additionalFeaturesBodyView address product

        body = tableView address headerRow bodyRows
    in
        panelView address heading body