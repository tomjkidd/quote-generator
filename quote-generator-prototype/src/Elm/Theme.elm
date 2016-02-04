module Theme
    ( crimsonTheme
    , ThemeStyle (..)
    , themeLookup
    )
    where

import Dict

type Theme = Crimson

currentTheme : Theme
currentTheme = Crimson

crimsonTheme : Dict.Dict String String
crimsonTheme =
    let ts = toString
    in Dict.fromList
        [ (ts LoginViewColor, "#262626")
        , (ts LoginViewTextColor, "white")
        , (ts ProductViewColor, "#A60010")
        , (ts FeatureViewColor, "#262626")
        , (ts FeatureViewTextColor, "white")
        ]

type ThemeStyle
    = LoginViewColor
    | LoginViewTextColor
    | ProductViewColor
    | FeatureViewColor
    | FeatureViewTextColor

themeLookup : ThemeStyle -> String
themeLookup key =
    let themeLookupDict =
            case currentTheme of
                Crimson -> crimsonTheme
        entry = Dict.get (toString key) themeLookupDict
    in
        case entry of
            Nothing -> ""
            Just e -> e
