module Decoders
    ( feature
    , product
    )
    where

import Json.Decode as Json exposing ((:=))

import Model exposing (Feature, Product)

-- http://www.troikatech.com/blog/2015/08/17/decoding-larger-json-objects-in-elm

apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
    Json.object2 (<|) func value

feature : Json.Decoder Feature
feature =
    Json.map Feature
        (Json.maybe ("id" := Json.int))
        `apply` ("title" := Json.string)
        `apply` ("description" := Json.string)
        `apply` ("cost" := Json.int)
        `apply` ("quantity" := Json.int)
        `apply` ("baseFeature" := Json.bool)
        `apply` (Json.maybe ("featureType" := Json.string))

product : Json.Decoder Product
product =
    Json.map Product
        (Json.maybe ("id" := Json.int))
        `apply` ("title" := Json.string)
        `apply` ("description" := Json.string)
        `apply` ("features" := Json.list feature)
        `apply` (Json.maybe ("note" := Json.string))
        `apply` (Json.maybe ("linkToSample" := Json.string))
        `apply` (Json.maybe ("quantity" := Json.int))
