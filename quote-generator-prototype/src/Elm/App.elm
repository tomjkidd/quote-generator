module App
    (initialModel, update, view, main, app, requestAuth, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox)
    where

{-| Eventually this will explain what is going on.
Everything is being thrown together for now to experiment with getting the prototype running. The goal is not to have it factored yet, because I still have to discover some of that for myself.

@docs initialModel, update, view, main, app

@docs requestAuth, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox

@docs sampleProduct
-}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Signal, Address)
import StartApp
--import Date exposing (Date)
import Effects exposing (Effects, Never)
import Task
import Json.Encode

import I18n exposing (i18nLookup)
import Uuid
import Common.Http
import Common.Buttons exposing (goToProductsButton, logoutButton)
import Common.Util exposing (show, removeAt, formatCurrency,
    calculateBaseCost, calculateTotalCost, calculateQuoteTotalCost)
import Common.Debug
import Sample.Data exposing (sampleFeatures, sampleProduct, sampleProducts)

import Model exposing (..)
import Action exposing (Action (..))
import Login
import Home
import ProductCatalog
import FeatureCatalog
import Encoders

showDebugPanel : Bool
showDebugPanel = False

initialQuote : Quote
initialQuote =
    { products = []
    , client = "Test Client"
    --, date = ?
    , preparer = Nothing
    , approved = False
    , id = Nothing
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
    , previousPage = Nothing
    , productCatalog = []
    , selectedProduct = Nothing
    , quote = initialQuote
    , confirmation = Nothing
    , antiForgery = Nothing
    }

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
                (NavigateToPage Home)
                    |> Task.succeed
                    |> Effects.task
            in
                ({ model | loggedIn = True}, Effects.batch [navEffect, requestProductCatalog, Common.Http.requestAntiForgeryToken])

        LogOut -> (initialModel, Effects.none)

        NavigateToPage page ->
            let currentPage = model.page
                confirmationEffect =
                    case currentPage of
                        SubmittedQuote ->
                            ClearConfirmation
                                |> Task.succeed
                                |> Effects.task

                        _ -> Effects.none
            in
                case model.loggedIn of
                    True -> ({ model | page = page, previousPage = Just currentPage }, confirmationEffect)
                    False -> ({ model | page = Login, previousPage = Nothing }, confirmationEffect)

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

        UpdateQuantity id qty ->
            let updateQty f =
                case f.baseFeature of
                    True -> f
                    False ->
                        case f.id of
                            Nothing -> f
                            Just fId ->
                                if id == fId && qty >= 0 then { f | quantity = qty } else f
            in
                case model.selectedProduct of
                    Nothing -> (model, Effects.none)
                    Just p ->
                        let newFeatures = List.map updateQty p.features
                            newProduct = { p | features = newFeatures}
                        in
                            ({ model | selectedProduct = Just newProduct }, Effects.none)

        AddProductToQuote product ->
            let
                oldQuote = model.quote
                newQuote = { oldQuote | products = oldQuote.products ++ [product] }
                navEffect =
                    (NavigateToPage QuoteSummary)
                        |> Task.succeed
                        |> Effects.task
            in
                ({ model | quote = newQuote }, navEffect)

        RemoveProductFromQuote index ->
            let
                oldQuote = model.quote
                oldProducts = oldQuote.products
                newProducts = removeAt index oldProducts
                newQuote = { oldQuote | products = newProducts }
            in
                ({ model | quote = newQuote }, Effects.none)

        RequestSubmitQuote q ->
            -- TODO: Take request and save
            let requestEffect = requestSubmitQuote q
            in
                (model, requestEffect)

        QuoteSubmitted uuid ->
            let
                getNavEffect id =
                    case id of
                        Nothing -> NavigateToPage QuoteSummary
                        Just _ -> NavigateToPage SubmittedQuote

                updateModel id model =
                    case id of
                        Nothing -> model
                        Just _ -> { model | confirmation = id, quote = initialQuote }

                navEffect =
                    getNavEffect uuid
                        |> Task.succeed
                        |> Effects.task

                messageEffect =
                    let effect =
                        case uuid of
                            Nothing ->
                                Error (i18nLookup I18n.QuoteSubmitFail)

                            Just _ ->
                                Notify (i18nLookup I18n.QuoteSubmittedTitle)
                    in
                        effect
                            |> Task.succeed
                            |> Effects.task

                newModel = updateModel uuid model
            in
                (newModel, Effects.batch [ navEffect, messageEffect ])

        Error msg ->
            (model, requestShowError msg)

        Notify msg ->
            (model, requestNotify msg)

        ClearConfirmation ->
            ({ model | confirmation = Nothing }, Effects.none)

        HttpRequestProducts ->
            (model, Common.Http.requestProducts)

        HttpRequestAnitForgeryToken ->
            (model, Common.Http.requestAntiForgeryToken)

        UpdateAntiForgeryToken af ->
            ({ model | antiForgery = Just af }, requestNotify (toString af))

removeProductFromQuoteButton : Address Action -> Model -> Int -> Html
removeProductFromQuoteButton address model index =
    button
        [ onClick address (RemoveProductFromQuote index)
        , show model.loggedIn
        ]
        [ i [class "fa fa-close", style [ ("padding-right", "5px") ]] []
        , text (i18nLookup I18n.RemoveProductFromQuote)
        ]

{-| -}
view : Address Action -> Model -> Html
view address model =
    div
        []
        [ Common.Debug.debugPanel address model showDebugPanel
        , div []
            [ headerView address model
            , Login.view address model
            , Home.view address model
            , ProductCatalog.view address model
            , FeatureCatalog.view address model
            , quoteSummaryView address model
            , submittedQuoteView address model
            ]
        ]

headerView : Address Action -> Model -> Html
headerView address model =
    div [ show (model.loggedIn) ]
        [ img [ src "images/header-logo.png", class "header-logo", height 50, width 300 ] []
        , button [ onClick address (NavigateToPage ProductCatalog), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToProductCatalog) ]
        , button [ onClick address (NavigateToPage QuoteSummary), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToQuoteSummary) ]
        , logoutButton address model
        ]

quoteSummaryProductView : Address Action -> Model -> Int -> Product -> Html
quoteSummaryProductView address model index product =
    let totalCost = calculateTotalCost product
    in
        div
            []
            [ div [] [ text product.title ]
            , div [] [ text (formatCurrency totalCost) ]
            , removeProductFromQuoteButton address model index
            ]


quoteSummaryView : Address Action -> Model -> Html
quoteSummaryView address model =
    let quoteHasProducts = model.quote.products /= []
        totalCost = calculateQuoteTotalCost model.quote
        productViews = List.indexedMap (quoteSummaryProductView address model) model.quote.products
    in
        div
            [ class "quote-summary-view"
            , show (model.page == QuoteSummary)
            ]

            [ div
                [ hidden quoteHasProducts]
                [ div [] [ text (i18nLookup I18n.NoProductsInQuote) ] ]
            , div [ class "products", show quoteHasProducts ] productViews
            , div [ class "quote-total-cost", show quoteHasProducts ] [ text (formatCurrency totalCost) ]
            , goToProductsButton address model
            , button [ onClick address (RequestSubmitQuote model.quote), show (model.loggedIn && model.quote.products /= []) ] [ text (i18nLookup I18n.SubmitQuote) ]
            ]

submittedQuoteView : Address Action -> Model -> Html
submittedQuoteView address model =
    div
        [ class "submitted-quote-view"
        , show (model.page == SubmittedQuote)
        ]

        [ div [] [ text (i18nLookup I18n.QuoteSubmittedTitle) ]
        , div [] [ text (i18nLookup I18n.QuoteSubmittedInfo) ]
        , div
            []
            [ text (i18nLookup I18n.ConfirmationNumber)
            , text (Uuid.toString model.confirmation)
            ]
        , goToProductsButton address model
        , logoutButton address model
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
requestAuth : Effects Action
requestAuth = requestAction RequestAuth Nothing

{-| -}
requestLogOut : Effects Action
requestLogOut = requestAction LogOut Nothing

requestShowError : String -> Effects Action
requestShowError str = requestAction (Error str) (Just str)

requestNotify : String -> Effects Action
requestNotify str = requestAction (Notify str) (Just str)

requestSubmitQuote : Quote -> Effects Action
requestSubmitQuote quote =
    let jsonQuote =
            quote
                |> Encoders.quote
                |> Json.Encode.encode 0
    in
        requestAction (RequestSubmitQuote quote) (Just jsonQuote)

-- https://groups.google.com/forum/#!msg/elm-discuss/cImJ7DdvKE0/Lskxb7twBAAJ

requestAction : Action -> Maybe String -> Effects Action
requestAction action str =
    let record =
        case action of
            RequestAuth -> { actionType = Just (toString action), data = Nothing }
            LogOut -> { actionType = Just (toString action), data = Nothing }

            Error msg -> { actionType = Just "Error", data = Just msg }

            Notify msg -> { actionType = Just "Notify", data = Just msg }

            RequestSubmitQuote quote ->
                { actionType = Just "RequestSubmitQuote"
                , data = str
                }

            _ -> { actionType = Nothing, data = Nothing }
    in
        Signal.send requestMailbox.address record
            |> Task.map (\t -> NoOp)
            |> Effects.task

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

{-| Provided to StartApp to translate JS to Elm responses into Actions -}
responsePortAction : Signal Action
responsePortAction = Signal.map
    (\response ->
        case response.actionType of
            Just "LogOut" -> LogOut
            Just "LogIn" -> LogIn
            Just "QuoteSubmitted" ->
                let guid = response.data
                    action =
                        case guid of
                            Nothing -> Error (i18nLookup I18n.QuoteSubmitFail)
                            Just g -> QuoteSubmitted (Uuid.toUuid g)
                in
                    action
            _ -> NoOp )
    responsePort

{-| A place to send request messages that will go out through requestPort -}
requestMailbox : Signal.Mailbox AppPortRequest
requestMailbox = Signal.mailbox { actionType = Nothing, data = Nothing }

{-| The port for outgoing Elm to JS messages -}
port requestPort : Signal AppPortRequest
port requestPort = requestMailbox.signal

{-| The port for incoming JS to Elm messages -}
port responsePort : Signal AppPortResponse

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
