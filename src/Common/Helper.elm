module Common.Helper exposing
    ( combineCosineParams
    , convertToRGB
    , findCosine
    , float2string
    , matchDimensionId
    )

import Debug
import List
import List.Extra as ListX
import Types
    exposing
        ( ColorSpace(..)
        , Cosine
        , DimensionId
        , defaultCosine
        )


float2string : Float -> String
float2string val =
    let
        vStr =
            String.fromInt <| round (val * 100)
    in
    case String.toList vStr of
        ones :: unders ->
            String.fromList <| ones :: [ '.' ] ++ unders

        _ ->
            String.fromFloat val


findCosine : DimensionId -> List Cosine -> Cosine
findCosine dimensionId cosines =
    let
        result =
            ListX.find (matchDimensionId dimensionId) cosines
    in
    Maybe.withDefault (defaultCosine dimensionId) result


matchDimensionId : DimensionId -> Cosine -> Bool
matchDimensionId dimensionId cosine =
    cosine.dimensionId == dimensionId


combineCosineParams : List Cosine -> Cosine -> List Cosine
combineCosineParams cosines global =
    let
        addGlobal =
            \cosine ->
                { cosine
                    | phase = cosine.phase + global.phase
                    , amplitude = cosine.amplitude + global.amplitude
                    , frequency = cosine.frequency + global.frequency
                    , offset = cosine.offset + global.offset
                }
    in
    List.map addGlobal cosines


convertToRGB : ColorSpace -> Cosine -> Cosine
convertToRGB colorSpace cosine =
    case colorSpace of
        RGB ->
            cosine

        _ ->
            cosine
