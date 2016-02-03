module App
    (Model, Page, Action, Feature, Product, Quote, initialModel, update, view, main, app, requestAuth, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox, sampleProduct, removeAt)
    where

{-| Eventually this will explain what is going on.
Everything is being thrown together for now to experiment with getting the prototype running. The goal is not to have it factored yet, because I still have to discover some of that for myself.

@docs Model, Page, Action, Feature, Product, Quote, initialModel, update, view, main, app

@docs requestAuth, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox

@docs sampleProduct, removeAt
-}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Signal, Address)
import StartApp
--import Date exposing (Date)
import Effects exposing (Effects, Never)
import Task
import Dict
--import Debug

import I18n exposing (i18nLookup)

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

{-| -}
type alias Model =
    { homeDetails : HomeDetails
    , loggedIn : Bool
    , page : Page
    , quote : Quote
    , productCatalog : List Product
    , selectedProduct : Maybe Product
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
    -- | Home -- Landing page for description of the tool
    | ProductCatalog -- Lists the available products
    | ProductFeatures
    | FeatureCatalog -- Lists the features for a given product
    | QuoteSummary -- Gives the current Quote
    -- | QuoteSubmitted -- Gives confirmation that quote was submitted

{-| -}
type Action
    = NoOp
    | RequestAuth -- Request info externally for Google auth
    -- | Auth String -- Perform auth check on user
    | RequestLogOut -- Request LogOut externally for Google auth
    | LogIn -- On valid user
    | LogOut -- Allow user to log out
    | RequestProductCatalog -- Get the list of Products as an Effect
    | LoadProducts (List Product) -- Update productCatalog with available Products
    | SelectProduct Product -- When product is chosen from list of products, candidate for Quote
    | LoadProductFeatures (List Feature) -- Loads features for product
    --| RequestFeatureCatalog Int -- Get the list of Features for a given Product
    | NavigateToPage Page -- Used to navigate the App
    --| UpdateFeature Feature
    --| UpdateProduct Product
    | AddProductToQuote Product
    | RemoveProductFromQuote Int
    | SubmitQuote
    --| QuoteSubmitted -- Perhaps notify user quote was submitted
    --| Error String -- Toastr with error for user

{-| Represents a component of a Product. -}
type alias Feature =
    { description : String
    , cost : Int
    , title : String
    , quantity: Int
    , id : Maybe Int
    , baseFeature : Bool -- True for base part of the report, false for addtional. A feature can show up as a base and additional feature.
    , featureType : Maybe String
    }

{-| Represents a Product offered by a provider. -}
type alias Product =
    { features : List Feature
    , description : String
    , title : String
    , id : Maybe Int
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
    , id : Maybe Int
    }

{-| -}
initialModel : Model
initialModel =
    { homeDetails =
        { title = i18nLookup I18n.HomeTitle
        , summary = i18nLookup I18n.HomeSummary
        , description = i18nLookup I18n.HomeDescription
        , navigateTo = ProductCatalog
        }
    , loggedIn = False
    , page = Login
    , productCatalog = []
    , selectedProduct = Nothing
    , quote =
        { products = []
        , client = "Test Client"
        --, date = ?
        , preparer = Nothing
        , approved = False
        , id = Nothing
        }
    }

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

requestProductCatalog : Effects Action
requestProductCatalog =
    Task.succeed (LoadProducts sampleProducts)
    |> Effects.task

requestProductFeatures : Int -> Effects Action
requestProductFeatures id =
    Task.succeed (LoadProductFeatures sampleFeatures)
    |> Effects.task

{-| -}
update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp -> (model, Effects.none)

        RequestAuth -> (model, requestAuth)

        RequestLogOut -> (model, requestLogOut)

        LogIn ->
            let navEffect =
                (NavigateToPage ProductCatalog)
                    |> Task.succeed
                    |> Effects.task
            in
                ({ model | loggedIn = True}, Effects.batch [navEffect, requestProductCatalog])

        LogOut -> (initialModel, Effects.none)

        NavigateToPage page ->
            case model.loggedIn of
                True -> ({ model | page = page }, Effects.none)
                False -> ({ model | page = Login }, Effects.none)

        RequestProductCatalog -> (model, requestProductCatalog)

        LoadProducts ps -> ({ model | productCatalog = ps }, Effects.none)

        SelectProduct p ->
            let navEffect =
                (NavigateToPage ProductFeatures)
                    |> Task.succeed
                    |> Effects.task
                requestEffect = Effects.none
                    {-case p.id of
                        Nothing -> Effects.none
                        Just pid -> requestProductFeatures pid-}
            in
                ({ model | selectedProduct = Just p }, Effects.batch [navEffect, requestEffect ])

        LoadProductFeatures fs ->
            case model.selectedProduct of
                Nothing -> (model, Effects.none)
                Just p ->
                    let newProduct = { p | features = fs }
                    in
                        ({ model | selectedProduct = Just newProduct }, Effects.none)

        AddProductToQuote product ->
            let
                oldQuote = model.quote
                newQuote = { oldQuote | products = oldQuote.products ++ [product] }
            in
                ({ model | quote = newQuote }, Effects.none)

        RemoveProductFromQuote index ->
            let
                oldQuote = model.quote
                oldProducts = oldQuote.products
                newProducts = removeAt index oldProducts
                newQuote = { oldQuote | products = newProducts }
            in
                ({ model | quote = newQuote }, Effects.none)

        SubmitQuote -> (initialModel, Effects.none)

{-| -}
view : Address Action -> Model -> Html
view address model =
  let btnClass =
    case model.loggedIn of
        True -> "btn btn-default btn-xs"
        False -> ""
  in
    div
        []
        [ text (toString model.page)
        , div []
            [ headerView address model

            -- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
            , loginView address model

            , button
                [ class btnClass, onClick address RequestAuth, show model.loggedIn ]
                [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
                , text "Request Auth"
                ]
            , productCatalogView address model
            , selectedProductView address model
            ]
        ]

loginView : Address Action -> Model -> Html
loginView address model =
    div
        [ class "login-view", hidden model.loggedIn, style [ ("width", "500px"),  ("margin", "0 auto")] ]
        [ div
            [ class "login-background"
            , style
                [ ("backgroundColor", themeLookup LoginViewColor)
                , ("color", themeLookup LoginViewTextColor)
                , ("display", "flex")
                , ("flex-direction", "row")

                ]
            ]
            [ img [ src "images/login-logo.png", width 100, height 100 ] []
            , div
                [ style [ ("align-self", "center"), ("justify-content", "center"), ("padding", "0 0 0 15px") ]]
                [ div [ class "login-title h2"] [ i18nLookup I18n.LoginTitle |> text ]
                , div [ class "login-subtitle h3"] [  i18nLookup I18n.LoginSubtitle |> text ]
                ]
            ]
        , googleSignInView address model
        ]

-- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
googleSignInView : Address Action -> Model -> Html
googleSignInView address model =
    div
        [ class "g-signin2"
        , style [ ("width", "120"), ("margin", "0 auto"), ("padding", "10px 0 0 0") ]
        , attribute "data-onsuccess" "onSignIn"
        , attribute "data-theme" "dark"
        ] []

productCatalogView : Address Action -> Model -> Html
productCatalogView address model =
    let products = List.map (productView address) model.productCatalog
    in
        div
            [ show (model.page == ProductCatalog) ]
            products

calculateBaseCost : Product -> Int
calculateBaseCost product =
    let baseFeatures = List.filter (\p -> p.baseFeature) product.features
        baseCost = List.foldl (\cur acc -> acc + (cur.cost * cur.quantity)) 0 baseFeatures
    in
        baseCost

calculateTotalCost : Product -> Int
calculateTotalCost product =
    let baseCost = calculateBaseCost product
        additionalFeatures = List.filter (\p -> not p.baseFeature) product.features
        additionalCost = List.foldl (\cur acc -> acc + (cur.cost * cur.quantity)) 0 additionalFeatures
    in
        baseCost + additionalCost

{-| Intentionally simple and for US -}
formatCurrency : Int -> String
formatCurrency value =
    "$ " ++ (toString value)

productView : Address Action -> Product -> Html
productView address product =
    let baseCost = calculateBaseCost product
    in
        div
            [ onClick address (SelectProduct product)
            , style
                [ ("backgroundColor", (themeLookup ProductViewColor))
                , ("margin", "5px 0")
                ]
            ]

            [ div [] [text product.title]
            , div [] [text product.description]
            , div [] [text (toString baseCost)]
            ]

selectedProductView : Address Action -> Model -> Html
selectedProductView address model =
    let product = model.selectedProduct
    in
        case product of
            Nothing -> div [ show (model.page == ProductFeatures) ] [ text "Not selected product..."]
            Just p ->
                div
                    [ show (model.page == ProductFeatures) ]
                    [ productDetailView address p ]

-- TODO: Create a base cost calculation, read only
-- TODO: Create a Quote Note input
-- TODO: Create a Total Cost field, read only
-- TODO: Create an Add To Quote button
-- TODO: Remane to FeatureCatalogView
productDetailView : Address Action -> Product -> Html
productDetailView address product =
    let
        baseCost = calculateBaseCost product
        totalCost = calculateTotalCost product
        baseFeatures = baseFeaturesView address product
        additionalFeatures = additionalFeaturesView address product
    in
        div [] ([ productView address product ] ++ [ baseFeatures, additionalFeatures ])

{-| Based on minimum needed to create a Bootstrap Panel -}
panelView : Address Action -> Html -> Html -> Html
panelView address heading body =
    let a = 1
    in
        div
            [ class "panel panel-default" ]
            [ div
                [ class "panel-heading" ]
                [ heading ]
            , div
                [ class "panel-body"]
                [ body ]
            ]

{-| Based on minimum needed to create a Bootstrap Table -}
tableView : Address Action -> Html -> List Html -> Html
tableView address headerRow bodyRows =
    table
        [ class "table table-striped" ]
        [ thead [] [ headerRow ]
        , tbody [] bodyRows
        ]

baseFeaturesHeaderView : Address Action -> Product -> Html
baseFeaturesHeaderView address product =
    let headerRow =
        tr
            []
            [ th [] [ text (i18nLookup I18n.Feature) ]
            , th [] [ text (i18nLookup I18n.Description) ]
            , th [] [ text (i18nLookup I18n.Type) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Cost) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Quantity) ]
            ]
    in
        headerRow

baseFeatureRowView : Address Action -> Feature -> Html
baseFeatureRowView address feature =
    tr
        []
        [ td [] [ text feature.title ]
        , td [] [ text feature.description ]
        , td [] [ text (Maybe.withDefault "" feature.featureType) ]
        , td [ class "text-right" ] [ text (formatCurrency feature.cost) ]
        , td [ class "text-center" ] [ text (toString feature.quantity) ]
        ]

baseFeaturesBodyView : Address Action -> Product -> List Html
baseFeaturesBodyView address product =
    let baseFeatures = (List.filter (\p -> p.baseFeature) product.features)
        bodyRows = (List.map (\f -> baseFeatureRowView address f) baseFeatures)
    in bodyRows


baseFeaturesView : Address Action -> Product -> Html
baseFeaturesView address product =
    let heading = text (i18nLookup I18n.BaseFeaturesTitle)

        headerRow = baseFeaturesHeaderView address product
        bodyRows = baseFeaturesBodyView address product

        body = tableView address headerRow bodyRows
    in
        panelView address heading body

additionalFeaturesHeaderView : Address Action -> Product -> Html
additionalFeaturesHeaderView address product =
    let headerRow =
        tr
            []
            [ th [] [ text (i18nLookup I18n.Feature) ]
            , th [] [ text (i18nLookup I18n.Description) ]
            , th [] [ text (i18nLookup I18n.Type) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Cost) ]
            , th [ class "text-center" ] [ text (i18nLookup I18n.Quantity) ]
            ]
    in
        headerRow

additionalFeatureRowView : Address Action -> Feature -> Html
additionalFeatureRowView address feature =
    tr
        []
        [ td [] [ text feature.title ]
        , td [] [ text feature.description ]
        , td [] [ text (Maybe.withDefault "" feature.featureType) ]
        , td [ class "text-right" ] [ text (formatCurrency feature.cost) ]
        , td [ class "text-center" ] [ text (toString feature.quantity) ]
        ]

additionalFeaturesBodyView : Address Action -> Product -> List Html
additionalFeaturesBodyView address product =
    let additionalFeatures = (List.filter (\p -> not p.baseFeature) product.features)
        bodyRows = (List.map (\f -> additionalFeatureRowView address f) additionalFeatures)
    in bodyRows

additionalFeaturesView : Address Action -> Product -> Html
additionalFeaturesView address product =
    let heading = text (i18nLookup I18n.AdditionalFeaturesTitle)
        headerRow = additionalFeaturesHeaderView address product
        bodyRows = additionalFeaturesBodyView address product

        body = tableView address headerRow bodyRows
    in
        panelView address heading body

{-| TODO: Remove if not needed. -}
featureView : Address Action -> Feature -> Html
featureView address feature =
    div
        [ style
            [ ("backgroundColor", (themeLookup FeatureViewColor))
            , ("color", (themeLookup FeatureViewTextColor))
            , ("margin", "5px")
            ]
        ]
        [ text feature.title, text (toString feature.cost) ]

headerView : Address Action -> Model -> Html
headerView address model =
    div [ show (model.loggedIn) ]
        [ img [ src "images/header-logo.png", class "header-logo", height 50, width 300 ] []
        , button [ onClick address (NavigateToPage ProductCatalog), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToProductCatalog) ]
        , button [ onClick address (NavigateToPage QuoteSummary), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToQuoteSummary) ]
        , button [ onClick address RequestLogOut, show model.loggedIn ] [ text (i18nLookup I18n.LogoutLabel) ]
        ]

{-| -}
app : StartApp.App Model
app =
  StartApp.start
    { init = (initialModel, Effects.none)
    , update = update
    , view = view
    , inputs = [ responsePortAction ]
    }

{-| -}
main : Signal Html
main =
  app.html

{-| -}
removeAt : Int -> List a -> List a
removeAt index xs =
    let
        tuples = List.indexedMap (,) xs
        filtered = List.filter (\(n, x) -> n /= index) tuples
        result = List.map (\(n, x) -> x) filtered
    in
        result

{-| Convenience function for Html manipulation -}
show : Bool -> Attribute
show b = hidden (not b)

{-| -}
requestAuth : Effects Action
requestAuth = Signal.send requestMailbox.address { actionType = Just "RequestAuth", data = Nothing }
    |> Task.map (\t -> NoOp)
    |> Effects.task

{-| -}
requestLogOut : Effects Action
requestLogOut = Signal.send requestMailbox.address { actionType = Just "LogOut", data = Nothing }
    |> Task.map (\t -> NoOp)
    |> Effects.task

-- https://groups.google.com/forum/#!msg/elm-discuss/cImJ7DdvKE0/Lskxb7twBAAJ

{-| -}
type alias AppPortRequest =
    { actionType : Maybe String
    , data : Maybe String
    }

{-| -}
type alias AppPortResponse =
    { actionType : Maybe String
    , data : Maybe String
    }

{-| -}
responsePortAction : Signal Action
responsePortAction = Signal.map
    (\response ->
        case response.actionType of
            Just "LogOut" -> LogOut
            Just "LogIn" -> LogIn
            _ -> NoOp )
    responsePort

{-| -}
requestMailbox : Signal.Mailbox AppPortRequest
requestMailbox = Signal.mailbox { actionType = Nothing, data = Nothing }

port requestPort : Signal AppPortRequest
port requestPort = requestMailbox.signal

port responsePort : Signal AppPortResponse

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
