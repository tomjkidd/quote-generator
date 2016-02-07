module Encoders
    ( feature
    , product
    , quote
    )
    where

import Json.Encode exposing (..)

import Model exposing (Feature, Product, Quote)
import Uuid

-- Is there a better way to handle nested records for JSON encoding?
-- [No](https://groups.google.com/forum/#!searchin/elm-discuss/json$20encode$20record/elm-discuss/LmtlxeNqsRw/GlYj0m44gLkJ), at least for now there appears to be no way to bypass creating these explicitly.
-- [Toward Automation](https://github.com/rtfeldman/elm-codify)

withNullDefault : (a -> Value) -> Maybe a -> Value
withNullDefault fn val =
    case val of
        Nothing -> null
        Just val -> fn val

feature : Feature -> Value
feature f =
    [ ("id", withNullDefault int f.id)
    , ("title", string f.title)
    , ("description", string f.description)
    , ("cost", int f.cost)
    , ("quantity", int f.quantity)
    , ("baseFeature", bool f.baseFeature)
    , ("featureType", withNullDefault string f.featureType)
    ]
    |> Json.Encode.object

product : Product -> Value
product p =
    [ ("id", withNullDefault int p.id)
    , ("title", string p.title)
    , ("description", string p.description)
    , ("features", list (List.map feature p.features))
    , ("note", withNullDefault string p.note)
    , ("linkToSample", withNullDefault string p.linkToSample)
    , ("quantity", withNullDefault int p.quantity)
    ]
    |> Json.Encode.object

quote : Quote -> Value
quote q =
    [ ("products", list (List.map product q.products))
    , ("client", string q.client)
    , ("preparer", withNullDefault string q.preparer)
    , ("approved", bool q.approved)
    , ("id", withNullDefault (\uuid -> string (Uuid.fromUuid uuid)) q.id)
    ]
    |> Json.Encode.object
