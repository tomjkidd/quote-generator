module Nav
    (view
    ) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)

import Action exposing (Action(..))
import Model exposing (Model, Page(..))
import Common.Util exposing (show)
import Common.Buttons exposing (goToProductsButton, logoutButton, helpButton)
import I18n exposing (I18nMessage(..))

{- DEPRECATED: This was the first nav menu, using a better styled version now -}
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
            , button [ onClick address (NavigateToPage Model.QuoteSummary), show model.loggedIn ] [ text (i18nLookup I18n.NavigateToQuoteSummary) ]
            , logoutButton i18nLookup address model
            , helpButton i18nLookup address model
            ]

navItemView : Address Action -> Model -> Maybe Page -> Action -> I18nMessage -> Maybe String -> Html
navItemView address model page action label icon =
    let i18nLookup = model.i18nLookup

        activeClass =
            case page of
                Nothing -> ""

                Just page' -> if model.page == page' then "active" else ""

        children =
            case icon of
                Nothing ->
                    [ text (i18nLookup label) ]

                Just icon' ->
                    [ i
                        [ class icon'
                        , style [ ("padding-right", "5px") ]
                        ]
                        []
                    , text (i18nLookup label)
                    ]
    in
    li
        [ class activeClass ]
        [ a
            [ href "#"
            , onClick address action
            , show model.loggedIn
            ]
            children
        ]

view : Address Action -> Model -> Html
view address model =
    let i18nLookup = model.i18nLookup
    in
        nav
            [ show (model.loggedIn)
            , class "navbar navbar-default navbar-static-top"
            ]
            [ div
                [ class "container-fluid" ]
                [ div
                    [ class "navbar-header" ]
                    [ img
                        [ alt "brand"
                        , src "images/header-logo.png"
                        , class "header-logo"
                        , height 50, width 300
                        , onClick address (NavigateToPage Home)
                        , style [ ("cursor", "pointer") ]
                        ]
                        []
                    ]

                , ul
                    [ class "nav navbar-nav navbar-right" ]
                    [ navItemView
                        address
                        model
                        (Just ProductCatalog)
                        (NavigateToPage ProductCatalog)
                        I18n.NavigateToProductCatalog
                        Nothing
                    , navItemView
                        address
                        model
                        (Just Model.QuoteSummary)
                        (NavigateToPage Model.QuoteSummary)
                        I18n.NavigateToQuoteSummary
                        Nothing
                    , navItemView
                        address
                        model
                        Nothing
                        RequestLogOut
                        I18n.LogoutLabel
                        Nothing
                    , navItemView
                        address
                        model
                        (Just Home)
                        (NavigateToPage Home)
                        I18n.Help
                        (Just "fa fa-question-circle")
                    ]
                ]
            ]
