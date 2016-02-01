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
--import Debug

{-| -}
type alias Model =
    { loggedIn : Bool
    , page : Page
    , quote : Quote
    , productCatalog : List Product
    , selectedProduct : Maybe Product
    --, featureCatalog : List Feature
    }

{-| Represents the currently selected page of the app -}
type Page
    = Login -- Manages user access to create Quotes
    -- | Home -- Landing page for description of the tool
    | ProductCatalog -- Lists the available products
    | ProductFeatures
    | FeatureCatalog
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
    }

{-| Represents a Product offered by a provider. -}
type alias Product =
    { features : List Feature
    , description : String
    , title : String
    , id : Maybe Int
    }

{-| Represents a Quote for a set of Products, used by a client to consider cost of services. -}
type alias Quote =
    { products : List Product
    , client : String
    --, date : Date
    , preparer : String
    , approved : Bool
    , id : Maybe Int
    }

{-| -}
initialModel : Model
initialModel =
    { loggedIn = False
    , page = Login
    , productCatalog = []
    , selectedProduct = Nothing
    , quote =
        { products = []
        , client = "Test Client"
        --, date = ?
        , preparer = "Tom Kidd"
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
    }

sampleProducts : List Product
sampleProducts =
    [
        { features = []
        , description = "This is a fake product 1"
        , title = "This is fake product's title 1"
        , id = Just 1
        },

        { features = []
        , description = "This is a fake product 2"
        , title = "This is fake product's title 2"
        , id = Just 2
        },

        { features = []
        , description = "This is a fake product 3"
        , title = "This is fake product's title 3"
        , id = Just 3
        }
    ]

sampleFeatures : List Feature
sampleFeatures =
    [
        { description = "Feature 1 description"
        , cost = 100
        , title = "Feature 1 title"
        , quantity = 1
        , id = Just 1
        },

        { description = "Feature 2 description"
        , cost = 200
        , title = "Feature 2 title"
        , quantity = 1
        , id = Just 2
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
                requestEffect =
                    case p.id of
                        Nothing -> Effects.none
                        Just pid -> requestProductFeatures pid
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
    div
        []
        [ text (toString model.page)
        , div []
            [ headerView address model

            -- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
            , googleSignInView model

            , button [ onClick address RequestAuth, show model.loggedIn ] [ text "Request Auth" ]

            , productCatalogView address model
            , selectedProductView address model
            ]
        ]

loginView : Address Action -> Model -> Html
loginView address model =
    div
        []
        [ text (toString model.page)
        , div []
            -- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
            [ googleSignInView model ]
        ]

googleSignInView : Model -> Html
googleSignInView model =
    div
        [ class "g-signin2"
        , attribute "data-onsuccess" "onSignIn"
        , attribute "data-theme" "dark"
        , hidden model.loggedIn
        ] []

productCatalogView : Address Action -> Model -> Html
productCatalogView address model =
    let products = List.map (productView address) model.productCatalog
    in
        div
            [ show (model.page == ProductCatalog) ]
            products


productView : Address Action -> Product -> Html
productView address product =
    div [ onClick address (SelectProduct product) ] [ text product.title ]


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

productDetailView : Address Action -> Product -> Html
productDetailView address product =
    let features = List.map (featureView address) product.features
    in
        div [] ([ text product.title ] ++ features)

featureView : Address Action -> Feature -> Html
featureView address feature =
    div [] [ text feature.title, text (toString feature.cost) ]

headerView : Address Action -> Model -> Html
headerView address model =
    div [ show (model.loggedIn) ]
        [ button [ onClick address (NavigateToPage ProductCatalog), show model.loggedIn ] [ text "Nav to Products" ]
        , button [ onClick address (NavigateToPage QuoteSummary), show model.loggedIn ] [ text "Quote Summary" ]
        , button [ onClick address RequestLogOut, show model.loggedIn ] [ text "Log Out" ]
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