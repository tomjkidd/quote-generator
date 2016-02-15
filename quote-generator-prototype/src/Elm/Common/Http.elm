module Common.Http
    ( requestProductCatalog
    , requestAntiForgeryToken
    , requestSubmitQuote
    , requestSubmitQuoteWithAntiForgeryToken
    , requestTranslations
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

getTask : String -> Json.Decoder a -> Task Http.Error a
getTask url decoder =
    let jsendRequest = Http.get (Decoders.jsend decoder) url
        unpackedResponse = Task.andThen jsendRequest (\(JSend jsend) ->
            Task.succeed jsend.data)
    in
        unpackedResponse

getEffect : String -> Json.Decoder a -> (a -> Action) -> Effects Action
getEffect url decoder dataToAction =
    let
        dataTask = getTask url decoder

        actionTask = Task.andThen dataTask (\v ->
            Task.succeed (dataToAction v))

        errorWrappedTask =
            Task.onError actionTask httpErrorHandler
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

{-| Makes a task that will make a request for antiforgery token and then perform the desired post -}
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

{-| DEPRECATED:
 Because the antiForgery token changes on the server and the client doesn't
 receive push notifications, this call sometimes resulted in failure because
 the token had changed. Use requestSubmitQuoteWithAntiForgeryToken -}
requestSubmitQuote : Quote -> AntiForgery -> Effects Action
requestSubmitQuote quote antiForgery =
    postEffect "quote" quote antiForgery Encoders.quote Decoders.submittedQuote
        (\response ->
            QuoteSubmitted (Uuid.toUuid response.uuid))

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

requestTranslations : String -> Effects Action
requestTranslations locale =
    let url = "translations/" ++ locale
    in
        getEffect url Decoders.translations (\ts -> LoadTranslations ts)
