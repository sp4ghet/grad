module Types exposing
    ( ColorSpace(..)
    , Cosine
    , CosineParam
    , DimensionId
    , Language(..)
    , Model
    , Msg(..)
    , defaultCosine
    )


type alias Model =
    { dimensions : Int
    , colorSpace : ColorSpace
    , cosines : List Cosine
    , global : Cosine
    , codeLanguage : Language
    , codeGradientSamples : Int
    }


type alias DimensionId =
    String


type alias CosineParam =
    String


type Msg
    = ChangeColorSpace String
    | UpdateCosine DimensionId CosineParam String
    | ChangeLanguage String
    | ChangeSampleCount Int


type alias Cosine =
    { dimensionId : String
    , phase : Float
    , amplitude : Float
    , frequency : Float
    , offset : Float
    }


defaultCosine : String -> Cosine
defaultCosine dimId =
    { dimensionId = dimId
    , phase = 0
    , amplitude = 1
    , frequency = 1
    , offset = 0
    }


type Language
    = GLSL
    | CSS
    | Unity


type ColorSpace
    = RGB
    | HSV
    | XYZ
    | CMYK
