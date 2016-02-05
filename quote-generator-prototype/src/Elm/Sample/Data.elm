module Sample.Data
    ( sampleProduct
    , sampleProducts
    , sampleFeatures
    )
    where

import Model exposing (Product, Feature)

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
    [
        { features = sampleFeatures
        , description = "This is a fake product 1 description."
        , title = "This is fake product's title 1"
        , id = Just 1
        , note = Nothing
        , linkToSample = Nothing
        , quantity = Nothing
        },

        { features = []
        , description = "This is a fake product 2 description"
        , title = "This is fake product's title 2"
        , id = Just 2
        , note = Nothing
        , linkToSample = Nothing
        , quantity = Nothing
        },

        { features = []
        , description = "This is a fake product 3 description"
        , title = "This is fake product's title 3"
        , id = Just 3
        , note = Nothing
        , linkToSample = Nothing
        , quantity = Nothing
        }
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
