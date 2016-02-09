module I18n
    ( SupportedLanguage (..)
    , englishI18nTranslations
    , I18nMessage (..)
    , i18nLookup
    )
    where

import Dict

type SupportedLanguage
    = English

currentLanguage : SupportedLanguage
currentLanguage = English

englishI18nTranslations : Dict.Dict String String
englishI18nTranslations =
    let ts = toString
    in
        Dict.fromList
            [(ts LoginTitle, "Login title goes here")
            ,(ts LoginSubtitle, "Login subtitle, if necessary")
            ,(ts HomeTitle, "Test home title")
            ,(ts HomeSummary, "Test home summary")
            ,(ts HomeDescription, "Test home description, long windedness.\n blah blah blah\n more blah blah.")
            ,(ts NavigateToProductCatalog, "Products")
            ,(ts GoToProductCatalog, "Go to Products")
            ,(ts NavigateToQuoteSummary, "Quote Summary")
            ,(ts QuoteSummary, "Quote Summary")
            ,(ts LogoutLabel, "Log Out")
            ,(ts ProductCatalogTitle, "Products")
            ,(ts FeatureCatalogTitle, "Features")
            ,(ts BaseFeaturesTitle, "Base Features")
            ,(ts AdditionalFeaturesTitle, "Additional Features")
            ,(ts Feature, "Feature")
            ,(ts Description, "Description")
            ,(ts Type, "Type")
            ,(ts Cost, "Cost")
            ,(ts UnitCost, "Unit Cost")
            ,(ts Quantity, "Quantity")
            ,(ts BaseCost, "Base Cost")
            ,(ts TotalCost, "Total Cost")
            ,(ts QuoteTotalCost, "Quote Total Cost")
            ,(ts QuoteNotes, "Quote Notes")
            ,(ts AddProductToQuote, "Add to Quote")
            ,(ts RemoveProductFromQuote, "Remove from Quote")
            ,(ts NoProductsInQuote, "There are currently no Products in the Quote.")
            ,(ts SubmitQuote, "Submit Quote")
            ,(ts QuoteSubmitFail, "Submitting the Quote resulted in an error.")
            ,(ts QuoteSubmittedTitle, "Quote Submitted")
            ,(ts QuoteSubmittedInfo, "The Quote was submitted. Please retain the confirmation number to identify this Quote in the future.")
            ,(ts ConfirmationNumber, "Confirmation Number")
            ,(ts LinkToSample, "Link To Sample")
            ]

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

i18nLookup : I18nMessage -> String
i18nLookup key =
    let i18nLookupDict =
            case currentLanguage of
                English -> englishI18nTranslations
        entry = Dict.get (toString key) i18nLookupDict
    in
        case entry of
            Nothing -> toString key
            Just e -> e
