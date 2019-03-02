module View exposing (view)

import Components.CodeSnippet exposing (codeSnippet)
import Components.ConfigMenu exposing (configMenu)
import Components.ControlPanel exposing (channelUi, globalUi)
import Components.Visualizer exposing (gradient, graph)
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
                [ graph model
                , gradient model
                ]
            , channelUi model
            , hr [] []
            , globalUi model.global
            , hr [] []
            , codeSnippet model
            ]
        ]
