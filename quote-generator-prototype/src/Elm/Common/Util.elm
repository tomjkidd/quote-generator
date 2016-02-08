module Common.Util
    ( show
    , formatCurrency
    , removeAt
    , calculateBaseCost, calculateTotalCost, calculateQuoteTotalCost
    )
    where

import Html exposing (Attribute)
import Html.Attributes exposing (hidden)

import Model exposing (Product, Quote)

{-| -}
removeAt : Int -> List a -> List a
removeAt index xs =
    let
        tuples = List.indexedMap (,) xs
        filtered = List.filter (\(n, x) -> n /= index) tuples
        result = List.map (\(n, x) -> x) filtered
    in
        result

{-| Convenience function for Html manipulation -}
show : Bool -> Attribute
show b = hidden (not b)

calculateBaseCost : Product -> Int
calculateBaseCost product =
    let baseFeatures = List.filter (\p -> p.baseFeature) product.features
        baseCost = List.foldl (\cur acc -> acc + (cur.cost * cur.quantity)) 0 baseFeatures
    in
        baseCost

calculateTotalCost : Product -> Int
calculateTotalCost product =
    let baseCost = calculateBaseCost product
        additionalFeatures = List.filter (\p -> not p.baseFeature) product.features
        additionalCost = List.foldl (\cur acc -> acc + (cur.cost * cur.quantity)) 0 additionalFeatures
    in
        baseCost + additionalCost

calculateQuoteTotalCost : Quote -> Int
calculateQuoteTotalCost quote =
    let totalCosts = List.map calculateTotalCost quote.products
    in
        List.foldl (+) 0 totalCosts
{-| Intentionally simple and for US -}
formatCurrency : Int -> String
formatCurrency value =
    "$" ++ (toString value)
