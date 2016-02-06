module Sample.Data
    ( sampleProduct
    , sampleProducts
    , sampleFeatures
    , sampleJsonFeature
    , sampleJsonProduct
    )
    where

import Json.Decode

import Model exposing (Product, Feature)
import Decoders

{-| -}
sampleProduct : Product
sampleProduct =
    { features = []
    , description = "This is a fake product"
    , title = "This is fake product's title"
    , id = Nothing
    , note = Nothing
    , linkToSample = Nothing
    , quantity = Nothing
    }

sampleProducts : List Product
sampleProducts =
    let jsonLoadedFeature = Json.Decode.decodeString Decoders.feature sampleJsonFeature
        jsonLoadedFeatures =
            case jsonLoadedFeature of
                Ok f -> [f]
                Err _ -> []
        jsonLoadedProduct = Json.Decode.decodeString Decoders.product sampleJsonProduct
        productToUse =
            case jsonLoadedProduct of
                Ok p -> p
                Err _ -> sampleProduct
    in
        [
            { features = sampleFeatures
            , description = "This is a fake product 1 description."
            , title = "This is fake product's title 1"
            , id = Just 1
            , note = Nothing
            , linkToSample = Nothing
            , quantity = Nothing
            },

            { features = jsonLoadedFeatures
            , description = "This is a fake product 2 description"
            , title = "This is fake product's title 2"
            , id = Just 2
            , note = Nothing
            , linkToSample = Nothing
            , quantity = Nothing
            },

            productToUse
        ]

sampleFeatures : List Feature
sampleFeatures =
    [
        { description = "Feature 1 description"
        , cost = 100
        , title = "Feature 1 title"
        , quantity = 3
        , id = Just 1
        , baseFeature = True
        , featureType = Nothing
        },

        { description = "Feature 2 description"
        , cost = 200
        , title = "Feature 2 title"
        , quantity = 1
        , id = Just 2
        , baseFeature = False
        , featureType = Nothing
        }
    ]

sampleJsonFeature : String
sampleJsonFeature =
 "{\"description\":\"Sample Json Feature Description\"
    ,\"multiplier\":0.15
    ,\"title\":\"Sample Json Feature Title\"
    ,\"featureType\":\"Test Type\"
    ,\"note\":\"Note for Test\"
    ,\"id\":1
    ,\"baseFeature\":true
    ,\"cost\":100.0
    ,\"quantity\":1
    }"

sampleJsonProduct : String
sampleJsonProduct =
    "{\"id\":1
    ,\"title\":\"Sample Json Product Title\"
    ,\"description\":\"Sample Json Product Description\"
    ,\"features\":
        [ {\"description\":\"Feature 1 Desc\"
            ,\"multiplier\":0.15
            ,\"title\":\"Feature 1 Title\"
            ,\"featureType\":\"Blah\"
            ,\"note\":\"Feature 1 note\"
            ,\"id\":1
            ,\"baseFeature\":true
            ,\"cost\":100.0
            ,\"quantity\":1
            }
        ,{\"description\":\"Feature 2 Desc\"
            ,\"multiplier\":0.15
            ,\"title\":\"Feature 2 Title\"
            ,\"featureType\":\"Blah\"
            ,\"note\":\"Feature 2 note\"
            ,\"id\":2
            ,\"baseFeature\":true
            ,\"cost\":200.0
            ,\"quantity\":1
            }
        ,{\"description\":\"Feature 3 Desc\"
            ,\"multiplier\":0.15
            ,\"title\":\"Feature 3 Title\"
            ,\"featureType\":\"Blah\"
            ,\"note\":\"Feature 3 note\"
            ,\"id\":3
            ,\"baseFeature\":false
            ,\"cost\":300.0
            ,\"quantity\":1
            }
        ]
    ,\"note\": null
    ,\"linkToSample\": null
    ,\"quantity\": null
    }"
