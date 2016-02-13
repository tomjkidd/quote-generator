module I18n
    ( SupportedLanguage (..)
    , englishI18nTranslations
    , I18nMessage(..)
    , i18nLookup
    , createTranslator
    )
    where

import Dict
import Task
import Model exposing (Translation)

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
            ,(ts HomeTitle, "Quote Generator Home")
            ,(ts HomeSummary, "Instructions")
            ,(ts HomeDescription, "A Quote is a list of Products.\nA Product is made up of Features.\nEach Product has a set of Base Features, which are mandatory.\nEach Product has a set of Additional Features, which are optional.\n\nUse the Products button to go to the list of products.\nSelect a Product to view it's Features. Additional Features may be added through the Quantity input. When you have the Product in the desired state, use the Add to Quote button to add it to your Quote. You will then be brought to the Quote Summary page.\n\nThe Quote Summary is like a shopping cart for the Products you want to create a Quote for. At any point, you can see what is in the existing Quote by clicking on the Quote Summary button. If you want to add more Products, use the Product button to go back to the list of products. If you want to remove a Product, use the X button to the right of the Product's Cost.\n\nWhen you have what you need in the Quote, Submit the Quote from the Quote Summary page.\n\nThese instructions are always available by clicking on the logo in the header as well as the Help button.")
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
            ,(ts Help, "Help")
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
    | Help

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
