module Common.Helper exposing (findCosine, matchDimensionId)

import Debug
import List.Extra as ListX
import Types
    exposing
        ( Cosine
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
