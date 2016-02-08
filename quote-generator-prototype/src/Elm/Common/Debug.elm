module Common.Debug
    (debugPanel
    )
    where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import Json.Decode
import Json.Encode

import Action exposing (Action (..))
import Model exposing (Model)
import Common.Util exposing (show)

import Sample.Data exposing (sampleQuote, sampleJsonFeature, sampleJsonProduct)
import Decoders
import Encoders

-- TODO: Create a simple wrapper for making these buttons.

requestAuthButton : Address Action -> Model -> Html
requestAuthButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address RequestAuth, show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Auth"
            ]

requestProductsButton : Address Action -> Model -> Html
requestProductsButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address HttpRequestProductCatalog, show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Products"
            ]

requestErrorButton : Address Action -> Model -> Html
requestErrorButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address (Error "This is an Error test"), show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Error"
            ]

requestNotifyButton : Address Action -> Model -> Html
requestNotifyButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address (Notify "This is a Notify test"), show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Notify"
            ]

debugPanel : Address Action -> Model -> Bool -> Html
debugPanel address model showDebugPanel =
    let featureDecodeTest = Json.Decode.decodeString Decoders.feature sampleJsonFeature
        productDecodeTest = Json.Decode.decodeString Decoders.product sampleJsonProduct
        featureEncodeTest =
            case featureDecodeTest of
                Ok f ->
                    (Encoders.feature f)
                    |> Json.Encode.encode 2
                    |> Just
                Err _ ->  Nothing
        productEncodeTest =
            case productDecodeTest of
                Ok p ->
                    (Encoders.product p)
                    |> Json.Encode.encode 2
                    |> Just
                Err _ -> Nothing
        quoteEncodeTest =
            (Encoders.quote sampleQuote)
                |> Json.Encode.encode 2
    in
        if showDebugPanel
            then
                div
                    []
                    [ div [] [ text (toString model.page) ]
                    , div [] [ text (toString model.quote) ]
                    , div [] [ text (toString model.confirmation) ]
                    , div [] [ text (toString featureDecodeTest) ]
                    , div [] [ text (toString productDecodeTest) ]
                    , div [] [ text (Maybe.withDefault "Encode did not succeed for feature" featureEncodeTest) ]
                    , div [] [ text (Maybe.withDefault "Encode did not succeed for product" productEncodeTest) ]
                    , div [] [ text quoteEncodeTest ]
                    , requestAuthButton address model
                    , requestProductsButton address model
                    , requestNotifyButton address model
                    , requestErrorButton address model
                    ]
            else div [] []
