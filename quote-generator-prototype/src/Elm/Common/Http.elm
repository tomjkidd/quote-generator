module Common.Http
    ( requestProductCatalog
    , requestAntiForgeryToken
    , requestSubmitQuote
    , requestSubmitQuoteWithAntiForgeryToken
    )
    where

import Http exposing (RawError(..), Error(..), Body)
import Task exposing (Task(..))
import Effects exposing (Effects, Never)
import Json.Decode as Json exposing ((:=))
import Json.Encode

import Model exposing (Quote, AntiForgery, SubmittedQuoteResponse)
import Action exposing (Action (..))
import Common.JSend exposing (JSend(..))
import Decoders
import Encoders
import Uuid

getEffect : String -> Json.Decoder a -> (a -> Action) -> Effects Action
getEffect url decoder dataToAction =
    let
        -- NOTE: This type annotation is correct, but will cause failure to compile, as mentioned here: https://github.com/elm-lang/elm-compiler/blob/0.16.0/hints/type-annotations.md
        --request : Task.Task Http.Error (JSend a)
        request = Http.get (Decoders.jsend decoder) url

        response = Task.andThen request (\(JSend jsend) ->
            Task.succeed (dataToAction jsend.data))

        errorWrappedTask =
            Task.onError response httpErrorHandler
    in
        errorWrappedTask
            |> Effects.task

{-| A variant of Http.post, to handle anti forgery token -}
post : AntiForgery -> Json.Decoder value -> String -> Body -> Task Error value
post antiForgery decoder url body =
  let request =
        { verb = "POST"
        , headers =
            [ ("X-CSRF-Token", antiForgery.csrfToken )
            , ("Content-Type", "application/json")
            ]
        , url = url
        , body = body
        }
  in
      Http.fromJson decoder (Http.send Http.defaultSettings request)

postEffect : String -> request -> AntiForgery -> (request -> Json.Encode.Value) -> Json.Decoder response -> (response -> Action) -> Effects Action
postEffect url requestData antiForgery encoder decoder dataToAction =
    let body =
            Json.Encode.encode 0 (encoder requestData)
                |> Http.string

        request = post antiForgery (Decoders.jsend decoder) url body

        response = Task.andThen request (\(JSend jsend) ->
            Task.succeed (dataToAction jsend.data))

        errorWrappedTask =
            Task.onError response httpErrorHandler
    in
        errorWrappedTask
            |> Effects.task

httpErrorHandler : Error -> Task a Action
httpErrorHandler err =
    case err of
        UnexpectedPayload str -> Task.succeed (Error str)
        BadResponse code str -> Task.succeed (Error str)
        _ -> Task.succeed (Error (toString err))

requestProductCatalog : Effects Action
requestProductCatalog =
    getEffect "products" Decoders.products (\ps -> LoadProducts ps)

requestAntiForgeryToken : Effects Action
requestAntiForgeryToken =
    getEffect "antiforgerytoken" Decoders.antiForgery (\af -> UpdateAntiForgeryToken af)

requestSubmitQuote : Quote -> AntiForgery -> Effects Action
requestSubmitQuote quote antiForgery =
    postEffect "quote" quote antiForgery Encoders.quote Decoders.submittedQuote
        (\response ->
            QuoteSubmitted (Uuid.toUuid response.uuid))

getTask : String -> Json.Decoder a -> Task Http.Error a
getTask url decoder =
    let jsendRequest = Http.get (Decoders.jsend decoder) url
        unpackedResponse = Task.andThen jsendRequest (\(JSend jsend) ->
            Task.succeed jsend.data)
    in
        unpackedResponse

postTask : String -> request -> AntiForgery -> (request -> Json.Encode.Value) -> Json.Decoder response -> Task Http.Error response
postTask url requestData antiForgery encoder decoder =
    let body =
            Json.Encode.encode 0 (encoder requestData)
                |> Http.string

        request = post antiForgery (Decoders.jsend decoder) url body

        unpackedResponse = Task.andThen request (\(JSend jsend) ->
            Task.succeed jsend.data)
    in
        unpackedResponse

requestSubmitQuoteWithAntiForgeryToken : Quote -> Effects Action
requestSubmitQuoteWithAntiForgeryToken q =
    let
        afTask : Task Http.Error AntiForgery
        afTask = getTask "antiforgerytoken" Decoders.antiForgery

        sqTask : Task Http.Error SubmittedQuoteResponse
        sqTask = Task.andThen afTask (\af ->
            postTask "quote" q af Encoders.quote Decoders.submittedQuote)

        actionTask : Task Http.Error Action
        actionTask = Task.andThen sqTask (\sq->
            Task.succeed (QuoteSubmitted (Uuid.toUuid sq.uuid)))

        errorWrappedTask : Task Never Action
        errorWrappedTask =
            Task.onError actionTask httpErrorHandler
    in
        errorWrappedTask
            |> Effects.task
