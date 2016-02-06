module Model
    ( Model
    , HomeDetails
    , Page (..)
    , Feature
    , Product
    , Quote
    )
    where

import Uuid

{-| -}
type alias Model =
    { homeDetails : HomeDetails
    , loggedIn : Bool
    , page : Page
    , previousPage : Maybe Page
    , quote : Quote
    , productCatalog : List Product
    , selectedProduct : Maybe Product
    , confirmation : Maybe Uuid.Uuid
    --, featureCatalog : List Feature
    --, TODO: Story for i18n (https://en.wikipedia.org/wiki/Internationalization_and_localization)
    }

type alias HomeDetails =
    { title : String
    , summary : String
    , description : String
    , navigateTo : Page
    }

{-| Represents the currently selected page of the app -}
type Page
    = Login -- Manages user access to create Quotes
    | Home -- Landing page for description of the tool
    | ProductCatalog -- Lists the available products
    | ProductFeatures
    | FeatureCatalog -- Lists the features for a given product
    | QuoteSummary -- Gives the current Quote
    | SubmittedQuote -- Gives confirmation that quote was submitted

{-| Represents a component of a Product. -}
type alias Feature =
    { id : Maybe Int
    , title : String
    , description : String
    , cost : Int
    , quantity: Int
    , baseFeature : Bool -- True for base part of the report, false for addtional. A feature can show up as a base and additional feature.
    , featureType : Maybe String
    }

{-| Represents a Product offered by a provider. -}
type alias Product =
    { id : Maybe Int
    , title : String
    , description : String
    , features : List Feature
    , note : Maybe String -- Available when creating a quote
    , linkToSample : Maybe String -- May be available to demonstrate a sample
    , quantity : Maybe Int -- Can have a value when adding to a quote
    }

{-| Represents a Quote for a set of Products, used by a client to consider cost of services. -}
type alias Quote =
    { products : List Product
    , client : String
    --, date : Date
    , preparer : Maybe String
    , approved : Bool
    , id : Maybe Uuid.Uuid
    }
