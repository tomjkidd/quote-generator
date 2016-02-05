module App
    (initialModel, update, view, main, app, requestAuth, requestLogOut, AppPortRequest, AppPortResponse, responsePortAction, requestMailbox, sampleProduct)
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
import String

import I18n exposing (i18nLookup)
import Theme exposing (themeLookup)
import Uuid
import Common.Buttons exposing (goToProductsButton, logoutButton)
import Common.Util exposing (show, removeAt, formatCurrency,
    calculateBaseCost, calculateTotalCost, calculateQuoteTotalCost)

import Model exposing (..)
import Action exposing (Action (..))
import Login
import Home
import ProductCatalog

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

requestSubmitQuote : Quote -> Effects Action
requestSubmitQuote quote =
    Task.succeed (QuoteSubmitted (Uuid.toUuid "33b446c6-8384-4953-b7a0-5ba0eb9d298f"))
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
                ({ model | loggedIn = True}, Effects.batch [navEffect, requestProductCatalog])

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

        SubmitQuote q ->
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

requestAuthButton : Address Action -> Model -> Html
requestAuthButton address model =
    let btnClass =
      case model.loggedIn of
          True -> "btn btn-default btn-xs"
          False -> ""
    in
        button
            [ class btnClass, onClick address RequestAuth, show model.loggedIn ]
            [ i [class "fa fa-cog", style [ ("padding-right", "5px") ]] []
            , text "Request Auth"
            ]

removeProductFromQuoteButton : Address Action -> Model -> Int -> Html
removeProductFromQuoteButton address model index =
    button
        [ onClick address (RemoveProductFromQuote index)
        , show model.loggedIn
        ]
        [ i [class "fa fa-close", style [ ("padding-right", "5px") ]] []
        , text (i18nLookup I18n.RemoveProductFromQuote)
        ]

debugPanel : Address Action -> Model -> Html
debugPanel address model =
    if showDebugPanel
        then
            div
                []
                [ div [] [ text (toString model.page) ]
                , div [] [ text (toString model.quote) ]
                , div [] [ text (toString model.confirmation) ]
                , requestAuthButton address model
                ]
        else div [] []

{-| -}
view : Address Action -> Model -> Html
view address model =
    div
        []
        [ debugPanel address model
        , div []
            [ headerView address model

            -- http://stackoverflow.com/questions/33420659/how-to-create-html-data-attributes-in-elm
            , Login.view address model
            , Home.view address model
            , ProductCatalog.view address model
            , selectedProductView address model
            , quoteSummaryView address model
            , submittedQuoteView address model
            ]
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
        div [] <|
            [ ProductCatalog.productView address product ] ++
            [ baseFeatures
            , div [ class "text-right"] [ text (formatCurrency baseCost)]
            , additionalFeatures
            , div [ class "text-right"] [ text (formatCurrency totalCost) ]
            , div
                [ class "submit-quote text-right"]
                [ button [ onClick address (AddProductToQuote product) ] [ text (i18nLookup I18n.AddProductToQuote) ]
                ]
            ]

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
        , td
            [ class "text-center" ]
            [ input
                [ value (toString feature.quantity)

                , type' "number"
                , on "input" targetValue
                    (\qty ->
                        case feature.id of
                            Nothing -> Signal.message address NoOp
                            Just id ->
                                let parsedQty = (String.toInt qty)
                                    action =
                                        case parsedQty of
                                            Err _ -> NoOp
                                            Ok n -> (UpdateQuantity id n)
                                in
                                    Signal.message address action)
                , style [ ("width", "50px") ]
                , class "text-right"
                ]
                []
            ]
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
            [ ("backgroundColor", (themeLookup Theme.FeatureViewColor))
            , ("color", (themeLookup Theme.FeatureViewTextColor))
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
            , button [ onClick address (SubmitQuote model.quote), show (model.loggedIn && model.quote.products /= []) ] [ text (i18nLookup I18n.SubmitQuote) ]
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
requestAuth = Signal.send requestMailbox.address { actionType = Just "RequestAuth", data = Nothing }
    |> Task.map (\t -> NoOp)
    |> Effects.task

{-| -}
requestLogOut : Effects Action
requestLogOut = Signal.send requestMailbox.address { actionType = Just "LogOut", data = Nothing }
    |> Task.map (\t -> NoOp)
    |> Effects.task

requestShowError : String -> Effects Action
requestShowError str = Signal.send requestMailbox.address { actionType = Just "Error", data = Just str }
    |> Task.map (\t -> NoOp)
    |> Effects.task

requestNotify : String -> Effects Action
requestNotify str = Signal.send requestMailbox.address { actionType = Just "Notify", data = Just str }
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
