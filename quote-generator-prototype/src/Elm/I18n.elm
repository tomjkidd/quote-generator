module I18n
    ( I18nMessage(..)
    , i18nLookup
    , Translation
    , createTranslator
    )
    where

import Dict

type I18nMessage
    = LoginTitle
    | LoginSubtitle
    | HomeTitle
    | HomeSummary
    | HomeDescription
    | NavigateToProductCatalog
    | GoToProductCatalog
    | QuoteSummary
    | NavigateToQuoteSummary
    | LogoutLabel
    | ProductCatalogTitle
    | FeatureCatalogTitle
    | BaseFeaturesTitle
    | AdditionalFeaturesTitle
    | Feature
    | Description
    | Type
    | Cost
    | UnitCost
    | Quantity
    | BaseCost
    | TotalCost
    | QuoteTotalCost
    | QuoteNotes
    | AddProductToQuote
    | RemoveProductFromQuote
    | NoProductsInQuote
    | SubmitQuote
    | QuoteSubmitFail
    | QuoteSubmittedTitle
    | QuoteSubmittedInfo
    | ConfirmationNumber
    | LinkToSample
    | Help

{-| A default for when no translations are loaded from the server. -}
i18nLookup : I18nMessage -> String
i18nLookup key =
    toString key

type alias Translation =
    { key: String
    , value: String
    , locale: String
    }

createTranslator : List Translation -> (I18nMessage -> String)
createTranslator ts =
    let translationList = List.map (\t -> (t.key, t.value)) ts
        i18nLookupDict = Dict.fromList translationList

        translator : I18nMessage -> String
        translator key =
            let entry = Dict.get (toString key) i18nLookupDict
            in
                case entry of
                    Nothing -> toString key
                    Just e -> e
    in
        translator
