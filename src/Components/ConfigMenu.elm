module Components.ConfigMenu exposing (configMenu)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Types exposing (Model, Msg(..))


configMenu : Model -> Html Msg
configMenu model =
    div [ class "config" ]
        [ div [ class "select" ]
            [ select [ onInput ChangeColorSpace ]
                [ option [ disabled True ] [ text "Color Space" ]
                , option [ value "RGB" ] [ text "RGB" ]
                , option [ value "HSV" ] [ text "HSV" ]
                , option [ disabled True, value "XYZ" ] [ text "XYZ" ]
                , option [ disabled True, value "CMYK" ] [ text "CMYK" ]
                ]
            ]
        , div [ class "select" ]
            [ select []
                [ option [ disabled True ] [ text "Preset" ]
                , option [ disabled True ] [ text "Garbage" ]
                ]
            ]
        ]
