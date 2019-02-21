module State exposing (init, update)

import Http exposing (Error(..))
import Json.Decode as Decode
import Types exposing (Model, Msg(..))


init : Int -> ( Model, Cmd Msg )
init flags =
    ( "", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        _ ->
            ( model, Cmd.none )
