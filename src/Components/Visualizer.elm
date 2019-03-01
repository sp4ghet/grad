module Components.Visualizer exposing (gradient, graph)

import Html exposing (..)
import Html.Attributes exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Types exposing (Cosine, Model, Msg(..))
import WebGL exposing (Mesh, Shader)


type alias Vertex =
    { position : Vec2.Vec2
    }


type alias Uniforms =
    { resolution : Vec2.Vec2
    }



-- root : Model -> Html msg
-- root model =
--     WebGL.toHtml
--         [ style
--             [ ( "position", "fixed" )
--             , ( "top", "0" )
--             , ( "left", "0" )
--             , ( "width", "100vw" )
--             , ( "height", "100vh" )
--             ]
--         ]
--         [ WebGL.entity
--             vertexShader
--             fragmentShader
--             mesh
--           <|
--             Uniforms (mouse2vec model.mousePos) (vec2 300 150)
--         ]


mesh : WebGL.Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec2 -1 -1)
          , Vertex (vec2 1 1)
          , Vertex (vec2 1 -1)
          )
        , ( Vertex (vec2 -1 -1)
          , Vertex (vec2 -1 1)
          , Vertex (vec2 1 1)
          )
        ]



-- Shaders


vertexShader : WebGL.Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
        attribute vec2 position;
        varying vec3 vcolor;
        void main () {
            gl_Position = vec4(position, 0., 1.0);
            vcolor = vec3(0.);
        }
    |]


fragmentShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
    precision mediump float;
    uniform vec2 resolution;
    varying vec3 vcolor;

    void main(){
      vec2 p = (gl_FragCoord.xy * 2. - resolution) / min(resolution.x, resolution.y);
      vec2 uv = gl_FragCoord.xy / resolution;
      vec4 color = vec4(uv.x, uv.y, 0.75, 1.);

      gl_FragColor = color;
    }
    |]


graph : Model -> Html Msg
graph model =
    WebGL.toHtml
        [ class "webgl-graph" ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
          <|
            Uniforms (vec2 300 150)
        ]


gradient : Model -> Html Msg
gradient model =
    WebGL.toHtml
        [ class "webgl-gradient" ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
          <|
            Uniforms (vec2 300 150)
        ]
