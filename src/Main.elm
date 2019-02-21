module Main exposing (main)

import Browser
import State exposing (init, update)
import Types exposing (Model, Msg(..))
import View exposing (view)


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "grad - Cosine Gradient in Multiple Color Spaces"
                , body = [ view m ]
                }
        , subscriptions = \_ -> Sub.none
        }
