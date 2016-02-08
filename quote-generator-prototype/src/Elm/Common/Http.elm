module Common.Http
    ( requestProductCatalog
    , requestAntiForgeryToken
    )
    where

import Http exposing (RawError(..))
import Task
import Effects exposing (Effects, Never)
import Json.Decode as Json exposing ((:=))

import Action exposing (Action (..))
import Common.JSend exposing (JSend(..))
import Decoders

getEffect : String -> Json.Decoder a -> (a -> Action) -> Effects Action
getEffect url decoder dataToAction =
    let
        -- NOTE: This type annotation is correct, but will cause failure to compile, as mentioned here: https://github.com/elm-lang/elm-compiler/blob/0.16.0/hints/type-annotations.md
        --request : Task.Task Http.Error (JSend a)
        request = Http.get (Decoders.jsend decoder) url
        response = Task.andThen request (\(JSend jsend) ->
            Task.succeed (dataToAction jsend.data))
        errorWrappedTask =
            Task.onError response (\err -> Task.succeed (Error (toString err)))
    in
        errorWrappedTask
            |> Effects.task

requestProductCatalog : Effects Action
requestProductCatalog =
    getEffect "products" Decoders.products (\ps -> LoadProducts ps)

requestAntiForgeryToken : Effects Action
requestAntiForgeryToken =
    getEffect "antiforgerytoken" Decoders.antiForgery (\af -> UpdateAntiForgeryToken af)
