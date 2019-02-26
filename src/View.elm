module View exposing (view)

import Components.CodeSnippet exposing (codeSnippet)
import Components.ConfigMenu exposing (configMenu)
import Components.ControlPanel exposing (channelUi, globalUi)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    div [ class "section" ]
        [ div [ class "container" ]
            [ h1 [ class "title" ] [ text "Cosine Gradient in Multiple Color Spaces" ]
            , configMenu model
            , div [ class "viz" ]
                [ div [ style "width" "80vw", style "height" "30vh", style "background-color" "magenta" ] []
                , div [ style "width" "80vw", style "height" "5vh", style "background-color" "cyan" ] []
                ]
            , channelUi model
            , globalUi model.global
            , codeSnippet model
            ]
        ]
