module Components.CodeSnippet exposing (codeSnippet)

import Html exposing (..)
import Html.Attributes exposing (..)
import Types exposing (Model, Msg(..))


codeSnippet : Model -> Html msg
codeSnippet model =
    div [ class "code-snippet" ]
        [ h2 [] [ text "Code Snippet" ]
        , div [ class "select" ]
            [ select []
                [ option [] [ text "Language" ]
                , option [] [ text "GLSL" ]
                , option [] [ text "Unity" ]
                ]
            ]
        , pre []
            [ code []
                [ p [] [ text "hoge" ]
                ]
            ]
        ]
