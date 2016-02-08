module Common.Http
    ( requestProductCatalog
    , requestAntiForgeryToken
    )
    where

import Http exposing (RawError(..))
import Task
import Effects exposing (Effects, Never)

import Action exposing (Action (..))
import Model exposing (Product, AntiForgery)
import Common.JSend exposing (JSend(..))
import Decoders

requestProductCatalog : Effects Action
requestProductCatalog =
    let url = "products"

        request : Task.Task Http.Error (JSend (List Product))
        request = Http.get (Decoders.jsend Decoders.products) url

        response = Task.andThen request (\(JSend jsend) ->
            Task.succeed (LoadProducts jsend.data))

        wrapped =
            Task.onError response (\err -> Task.succeed (Error (toString err)))

    in
        wrapped
            |> Effects.task

requestAntiForgeryToken : Effects Action
requestAntiForgeryToken =
    let url = "antiforgerytoken"

        request : Task.Task Http.Error (JSend AntiForgery)
        request = Http.get (Decoders.jsend Decoders.antiForgery) url

        response = Task.andThen request (\(JSend jsend) ->
            Task.succeed (UpdateAntiForgeryToken jsend.data))

        wrapped =
            Task.onError response (\err -> Task.succeed (Error (toString err)))
    in
        wrapped
            |> Effects.task
