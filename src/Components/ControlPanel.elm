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
        map (\x -> sliderSet x) <|
            model.cosines


globalUi : Cosine -> Html Msg
globalUi global =
    div [ class "global-ui" ]
        [ sliderSet global ]


sliderSet : Cosine -> Html Msg
sliderSet cosine =
    div [ class "columns" ]
        [ div [ class "column" ] [ sliderValue cosine.phase cosine.dimensionId "phase" ]
        , div [ class "column" ] [ sliderValue cosine.amplitude cosine.dimensionId "amplitude" ]
        , div [ class "column" ] [ sliderValue cosine.frequency cosine.dimensionId "frequency" ]
        , div [ class "column" ] [ sliderValue cosine.offset cosine.dimensionId "offset" ]
        ]


sliderValue : Float -> DimensionId -> CosineParam -> Html Msg
sliderValue val dimensionId paramId =
    div []
        [ input
            [ class "slider"
            , step "0.01"
            , Attr.min "0"
            , Attr.max "1"
            , value <| String.fromFloat val
            , type_ "range"
            , onInput <| UpdateCosine dimensionId paramId
            ]
            []
        , input
            [ Attr.min "0"
            , Attr.max "1"
            , type_ "number"
            , onInput <| UpdateCosine dimensionId paramId
            , value <| String.fromFloat val
            ]
            []
        ]
