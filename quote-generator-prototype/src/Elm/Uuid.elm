module Uuid
    ( Uuid
    , toUuid
    , toString
    )
    where

import Regex

type Uuid = Uuid String

isValid : String -> Bool
isValid id =
  Regex.contains uuidRegex id

uuidRegex : Regex.Regex
uuidRegex =
  Regex.regex "^[0-9A-Fa-f]{8,8}-[0-9A-Fa-f]{4,4}-[1-5][0-9A-Fa-f]{3,3}-[8-9A-Ba-b][0-9A-Fa-f]{3,3}-[0-9A-Fa-f]{12,12}$"

toUuid : String -> Maybe Uuid
toUuid str =
    case isValid str of
        True -> Just (Uuid str)
        False -> Nothing

toString : Maybe Uuid -> String
toString id =
    case id of
        Nothing -> ""
        Just (Uuid str) -> str
