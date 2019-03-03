module CodeGen.CSS exposing (render)

import Types exposing (Cosine)


render : List Cosine -> String
render cosines =
    "css"
