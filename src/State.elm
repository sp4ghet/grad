module State exposing (init, update)

import Common.Helper exposing (findCosine, matchDimensionId)
import Http exposing (Error(..))
import Json.Decode as Decode
import List exposing (map)
import List.Extra as ListX
import String
import Types
    exposing
        ( ColorSpace(..)
        , Cosine
        , CosineParam
        , DimensionId
        , Language(..)
        , Model
        , Msg(..)
        , defaultCosine
        )


init : a -> ( Model, Cmd Msg )
init _ =
    ( { dimensions = 3
      , colorSpace = RGB
      , cosines =
            map defaultCosine <|
                [ "R", "G", "B" ]
      , global = { dimensionId = "global", phase = 0, amplitude = 0, frequency = 0, offset = 0 }
      , codeLanguage = GLSL
      , codeGradientSamples = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ChangeColorSpace colorSpaceString ->
            let
                newColorSpace =
                    parseColorSpaceString colorSpaceString model.colorSpace

                dimensions =
                    dimensionsFromColorSpace newColorSpace

                cosines =
                    if model.dimensions >= dimensions then
                        List.take dimensions model.cosines

                    else
                        model.cosines ++ [ defaultCosine "" ]

                dimIds =
                    dimIdsFromColorSpace newColorSpace

                properCosines =
                    List.map2 (\ids cosine -> { cosine | dimensionId = ids }) dimIds cosines
            in
            ( { model
                | dimensions = dimensions
                , colorSpace = newColorSpace
                , cosines = properCosines
              }
            , Cmd.none
            )

        ChangeLanguage languageString ->
            let
                newLanguage =
                    parseLanguage languageString model.codeLanguage
            in
            ( { model | codeLanguage = newLanguage }, Cmd.none )

        ChangeSampleCount newGradientSamples ->
            ( { model | codeGradientSamples = newGradientSamples }, Cmd.none )

        UpdateCosine dimensionId cosineParam newValueString ->
            let
                newValueMaybe =
                    String.toFloat newValueString

                newValue =
                    case newValueMaybe of
                        Just val ->
                            val

                        Nothing ->
                            0.0

                newCosines =
                    ListX.updateIf
                        (matchDimensionId dimensionId)
                        (updateCosine cosineParam newValue)
                        model.cosines
            in
            if dimensionId == "global" then
                ( { model | global = updateCosine cosineParam newValue model.global }, Cmd.none )

            else
                ( { model | cosines = newCosines }, Cmd.none )


updateCosine : CosineParam -> Float -> Cosine -> Cosine
updateCosine cosineParam newValue cosine =
    case cosineParam of
        "phase" ->
            { cosine | phase = newValue }

        "amplitude" ->
            { cosine | amplitude = newValue }

        "frequency" ->
            { cosine | frequency = newValue }

        "offset" ->
            { cosine | offset = newValue }

        _ ->
            cosine


parseLanguage : String -> Language -> Language
parseLanguage languageString currentLanguage =
    case languageString of
        "GLSL" ->
            GLSL

        "Unity" ->
            Unity

        "CSS" ->
            CSS

        _ ->
            currentLanguage


parseColorSpaceString : String -> ColorSpace -> ColorSpace
parseColorSpaceString colorSpaceString currentColorSpace =
    case colorSpaceString of
        "RGB" ->
            RGB

        "XYZ" ->
            XYZ

        "CMYK" ->
            CMYK

        "HSV" ->
            HSV

        _ ->
            currentColorSpace


dimIdsFromColorSpace : ColorSpace -> List String
dimIdsFromColorSpace colorSpace =
    case colorSpace of
        RGB ->
            [ "R", "G", "B" ]

        XYZ ->
            [ "X", "Y", "Z" ]

        CMYK ->
            [ "C", "M", "Y", "K" ]

        HSV ->
            [ "H", "S", "V" ]


dimensionsFromColorSpace : ColorSpace -> Int
dimensionsFromColorSpace colorSpace =
    case colorSpace of
        RGB ->
            3

        XYZ ->
            3

        CMYK ->
            4

        HSV ->
            3
