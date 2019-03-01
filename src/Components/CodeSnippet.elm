module Components.CodeSnippet exposing (codeSnippet)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (Model, Msg(..))


codeSnippet : Model -> Html Msg
codeSnippet model =
    div [ class "code-snippet" ]
        [ h2 [] [ text "Code Snippet" ]
        , div [ class "select" ]
            [ select [ onInput ChangeLanguage ]
                [ option [ disabled True ] [ text "Language" ]
                , option [ value "GLSL" ] [ text "GLSL" ]
                , option [ value "Unity" ] [ text "Unity" ]
                , option [ value "CSS" ] [ text "CSS" ]
                ]
            ]
        , pre []
            [ code []
                [ p [] [ text "hoge" ]
                ]
            ]
        ]
