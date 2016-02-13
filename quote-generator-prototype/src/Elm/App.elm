module App
    (initialModel, update, view, main, app, requestConsoleLog, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox)
    where

{-| Eventually this will explain what is going on.
Everything is being thrown together for now to experiment with getting the prototype running. The goal is not to have it factored yet, because I still have to discover some of that for myself.

@docs initialModel, update, view, main, app

@docs requestConsoleLog, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox

@docs sampleProduct
-}
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Signal, Address)
import StartApp
--import Date exposing (Date)
import Effects exposing (Effects, Never, task)
import Task

import I18n exposing (i18nLookup, createTranslator)
import Uuid
import Common.Http
import Common.Buttons exposing (goToProductsButton, logoutButton, helpButton)
import Common.Util exposing (show, removeAt, formatCurrency,
    calculateBaseCost, calculateTotalCost, calculateQuoteTotalCost)
import Common.Debug

import Model exposing (..)
import Action exposing (Action (..))
import Login
import Home
import ProductCatalog
import FeatureCatalog
import QuoteSummary
import SubmittedQuote

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
        { title = I18n.HomeTitle
        , summary = I18n.HomeSummary
        , description = I18n.HomeDescription
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
    , i18nLookup = i18nLookup
    }

{-| -}
update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp -> (model, Effects.none)

        RequestConsoleLog msg -> (model, requestConsoleLog msg)

        RequestLogOut -> (model, requestLogOut)

        LogIn ->
            let navEffect =
                (NavigateToPage Home)
                    |> Task.succeed
                    |> Effects.task
            in
                ({ model | loggedIn = True}
                , Effects.batch
                    [ navEffect
                    , Common.Http.requestProductCatalog
                    --, Common.Http.requestAntiForgeryToken
                    ])

        LogOut -> ({ initialModel | i18nLookup = model.i18nLookup }, Effects.none)

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

        HttpRequestProductCatalog ->
            (model, Common.Http.requestProductCatalog)

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

        {-LoadProductFeatures fs ->
            case model.selectedProduct of
                Nothing -> (model, Effects.none)
                Just p ->
                    let newProduct = { p | features = fs }
                    in
                        ({ model | selectedProduct = Just newProduct }, Effects.none)-}

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
                newQuote = { oldQuote | products = oldQuote.products ++ [ { product | quantity = Just 1 } ] }
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


        HttpRequestSubmitQuote q ->
            (model, Common.Http.requestSubmitQuoteWithAntiForgeryToken q)
            -- TODO: Remove the antiForgery model code if the pattern should
            --       be to just get the token before every post.
            {-case model.antiForgery of
                Nothing ->
                    (model, Effects.none)
                Just af ->
                    (model, Common.Http.requestSubmitQuoteWithAntiForgeryToken q)-}

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
                                Error (model.i18nLookup I18n.QuoteSubmitFail)

                            Just _ ->
                                Notify (model.i18nLookup I18n.QuoteSubmittedTitle)
                    in
                        effect
                            |> Task.succeed
                            |> Effects.task

                newModel = updateModel uuid model
            in
                (newModel, Effects.batch [ navEffect, messageEffect ])

        Error msg ->
            (model, requestShowError msg)

        TranslateError key ->
            (model, requestShowError (model.i18nLookup key))

        Notify msg ->
            (model, requestNotify msg)

        ClearConfirmation ->
            ({ model | confirmation = Nothing }, Effects.none)

        HttpRequestAnitForgeryToken ->
            (model, Common.Http.requestAntiForgeryToken)

        UpdateAntiForgeryToken af ->
            ({ model | antiForgery = Just af }, requestConsoleLog (toString af))

        LoadTranslations ts ->
            let translator = createTranslator ts
            in
                ({ model | i18nLookup = translator}, Effects.none)

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
            , QuoteSummary.view address model
            , SubmittedQuote.view address model
            ]
        ]

headerView : Address Action -> Model -> Html
headerView address model =
    let i18nLookup = model.i18nLookup
    in
        div [ show (model.loggedIn) ]
            [ img [ src "images/header-logo.png", class "header-logo", height 50, width 300
            , style [("padding", "5px"), ("cursor", "pointer")]
            , onClick address (NavigateToPage Home)
            ] []
            , button [ onClick address (NavigateToPage ProductCatalog), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToProductCatalog) ]
            , button [ onClick address (NavigateToPage QuoteSummary), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToQuoteSummary) ]
            , logoutButton i18nLookup address model
            , helpButton i18nLookup address model
            ]

{-| -}
app : StartApp.App Model
app =
  StartApp.start
    { init = (initialModel, Common.Http.requestTranslations "en-US")
    , update = update
    , view = view
    , inputs = [ responsePortAction ]
    }

{-| -}
main : Signal Html
main =
  app.html

{-| -}
requestConsoleLog : String -> Effects Action
requestConsoleLog str = requestAction (RequestConsoleLog str) Nothing

{-| -}
requestLogOut : Effects Action
requestLogOut = requestAction LogOut Nothing

requestShowError : String -> Effects Action
requestShowError str = requestAction (Error str) (Just str)

requestNotify : String -> Effects Action
requestNotify str = requestAction (Notify str) (Just str)

-- https://groups.google.com/forum/#!msg/elm-discuss/cImJ7DdvKE0/Lskxb7twBAAJ

requestAction : Action -> Maybe String -> Effects Action
requestAction action str =
    let record =
        case action of
            RequestConsoleLog msg -> { actionType = Just "RequestConsoleLog", data = Just msg }
            LogOut -> { actionType = Just (toString action), data = Nothing }

            Error msg -> { actionType = Just "Error", data = Just msg }

            Notify msg -> { actionType = Just "Notify", data = Just msg }

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
                            Nothing -> TranslateError I18n.QuoteSubmitFail
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
