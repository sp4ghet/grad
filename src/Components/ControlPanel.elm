module Components.ControlPanel exposing (channelUi, globalUi)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (string)
import List exposing (map, range)
import String
import Types
    exposing
        ( Cosine
        , CosineParam
        , DimensionId
        , Model
        , Msg(..)
        )


channelUi : Model -> Html Msg
channelUi model =
    div [ class "channel-ui" ] <|
        [ div [ class "columns" ]
            [ div [ class "column" ] [ text "Channel" ]
            , div [ class "column" ] [ text "Phase" ]
            , div [ class "column" ] [ text "Amplitude" ]
            , div [ class "column" ] [ text "Frequency" ]
            , div [ class "column" ] [ text "Offset" ]
            ]
        ]
            ++ map (\x -> sliderSet x) model.cosines


globalUi : Cosine -> Html Msg
globalUi global =
    div [ class "global-ui" ]
        [ sliderSet global ]


sliderSet : Cosine -> Html Msg
sliderSet cosine =
    div [ class "columns" ]
        [ div [ class "column" ] [ text cosine.dimensionId ]
        , div [ class "column" ] [ sliderValue cosine.phase cosine.dimensionId "phase" ]
        , div [ class "column" ] [ sliderValue cosine.amplitude cosine.dimensionId "amplitude" ]
        , div [ class "column" ] [ sliderValue cosine.frequency cosine.dimensionId "frequency" ]
        , div [ class "column" ] [ sliderValue cosine.offset cosine.dimensionId "offset" ]
        ]


sliderValue : Float -> DimensionId -> CosineParam -> Html Msg
sliderValue val dimensionId paramId =
    let
        range =
            case dimensionId of
                "global" ->
                    case paramId of
                        "phase" ->
                            { min = "-1", max = "1" }

                        "amplitude" ->
                            { min = "-5", max = "5" }

                        "frequency" ->
                            { min = "-5", max = "5" }

                        "offset" ->
                            { min = "-1", max = "1" }

                        _ ->
                            { min = "0", max = "1" }

                _ ->
                    case paramId of
                        "phase" ->
                            { min = "0", max = "1" }

                        "amplitude" ->
                            { min = "0", max = "5" }

                        "frequency" ->
                            { min = "0", max = "5" }

                        "offset" ->
                            { min = "0", max = "1" }

                        _ ->
                            { min = "0", max = "1" }
    in
    div []
        [ input
            [ class "slider"
            , step "0.01"
            , Attr.min range.min
            , Attr.max range.max
            , value <| String.fromFloat val
            , type_ "range"
            , onInput <| UpdateCosine dimensionId paramId
            ]
            []
        , span [] [ text " " ]
        , input
            [ Attr.min range.min
            , Attr.max range.max
            , step "0.01"
            , type_ "number"
            , onInput <| UpdateCosine dimensionId paramId
            , value <| String.fromFloat val
            ]
            []
        ]
