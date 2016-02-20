module Action
    (Action (..))
    where

import Model exposing (Page, Feature, Product, Quote, AntiForgery)
import I18n exposing (I18nMessage(..), Translation)
import Uuid

{-| -}
type Action
    = NoOp
    | RequestConsoleLog String -- Request log to browser console
    -- | Auth String -- Perform auth check on user
    | RequestLogOut -- Request LogOut externally for Google auth
    | LogIn String -- On valid user
    | LogOut -- Allow user to log out
    | HttpRequestProductCatalog -- Make http request for products in catalog
    | LoadProducts (List Product) -- Update productCatalog with available Products
    | SelectProduct Product -- When product is chosen from list of products, candidate for Quote
    --| LoadProductFeatures (List Feature) -- Loads features for product, may not be needed.
    --| RequestFeatureCatalog Int -- Get the list of Features for a given Product
    | NavigateToPage Page -- Used to navigate the App
    --| UpdateFeature Feature
    --| UpdateProduct Product
    | UpdateQuantity Int Int -- Id Quantity
    | AddProductToQuote Product
    | RemoveProductFromQuote Int -- Index into Quote.products
    | HttpRequestSubmitQuote Quote -- Make http request to save current quote
    | QuoteSubmitted (Maybe Uuid.Uuid) -- Perhaps notify user quote was submitted
    | ClearConfirmation
    | Notify String -- Toastr with notification for user
    | Error String -- Toastr with error for user
    | TranslateError I18nMessage
    | HttpRequestAnitForgeryToken -- Make http request for anti forgery info
    | UpdateAntiForgeryToken AntiForgery -- Capture the anti forgery token
    | LoadTranslations (List Translation) -- Load translations for a
