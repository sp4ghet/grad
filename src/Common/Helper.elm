module Common.Helper exposing (combineCosineParams, convertToRGB, findCosine, matchDimensionId)

import Debug
import List
import List.Extra as ListX
import Types
    exposing
        ( ColorSpace(..)
        , Cosine
        , DimensionId
        )


findCosine : DimensionId -> List Cosine -> Cosine
findCosine dimensionId cosines =
    let
        result =
            ListX.find (matchDimensionId dimensionId) cosines
    in
    case result of
        Just cosine ->
            cosine

        Nothing ->
            Debug.todo "No such dimension when searching for a cosine object"


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
