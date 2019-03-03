module Components.CodeSnippet exposing (codeSnippet)

import CodeGen.CSS as G_CSS
import CodeGen.GLSL as G_GLSL
import CodeGen.Unity as G_Unity
import Common.Helper exposing (combineCosineParams)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (Cosine, Language(..), Model, Msg(..))


codeSnippet : Model -> Html Msg
codeSnippet model =
    div [ class "code-snippet" ]
        [ h2 [] [ text "Code Snippet" ]
        , div [ class "select" ]
            [ select [ onInput ChangeLanguage ]
                [ option [ disabled True ] [ text "Language" ]
                , option [ value "GLSL" ] [ text "GLSL" ]
                , option [ disabled True, value "Unity" ] [ text "Unity" ]
                , option [ disabled True, value "CSS" ] [ text "CSS" ]
                ]
            ]
        , pre []
            [ code []
                [ p [] [ text <| codeGen model ]
                ]
            ]
        ]


codeGen : Model -> String
codeGen model =
    let
        cosines =
            combineCosineParams model.cosines model.global
    in
    case model.codeLanguage of
        GLSL ->
            G_GLSL.render model.colorSpace cosines

        Unity ->
            G_Unity.render cosines

        CSS ->
            G_CSS.render cosines
