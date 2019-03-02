module Components.Visualizer exposing (gradient, graph)

import Common.Helper exposing (combineCosineParams, convertToRGB)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import List.Extra as ListX exposing (getAt)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Types exposing (ColorSpace, Cosine, Model, Msg(..))
import WebGL exposing (Mesh, Shader)



-- Exposed


graph : Model -> Html Msg
graph model =
    let
        cosines =
            combineCosineParams model.cosines model.global

        phases =
            createPhasesVec cosines

        amplitudes =
            createAmplitudeVec cosines

        frequencies =
            createFrequencyVec cosines

        offsets =
            createOffsetVec cosines
    in
    div
        [ class "webgl-graph"
        , class "container"
        ]
        [ WebGL.toHtml
            [ width 800, height 400 ]
            [ WebGL.entity
                vertexShader
                graphShader
                mesh
              <|
                { resolution = vec2 800 400
                , phase = phases
                , amplitude = amplitudes
                , frequency = frequencies
                , offset = offsets
                }
            ]
        ]


gradient : Model -> Html Msg
gradient model =
    let
        cosines =
            combineCosineParams model.cosines model.global

        phases =
            createPhasesVec cosines

        amplitudes =
            createAmplitudeVec cosines

        frequencies =
            createFrequencyVec cosines

        offsets =
            createOffsetVec cosines
    in
    div
        [ class "webgl-gradient"
        , class "container"
        ]
        [ WebGL.toHtml
            [ width 800, height 50 ]
            [ WebGL.entity
                vertexShader
                gradientShader
                mesh
              <|
                { resolution = vec2 800 50
                , phase = phases
                , amplitude = amplitudes
                , frequency = frequencies
                , offset = offsets
                }
            ]
        ]



-- Helpers


createPhasesVec : List Cosine -> Vec4
createPhasesVec cosines =
    let
        phases =
            List.map (\x -> x.phase) cosines

        phase_0 =
            Maybe.withDefault 0 <| getAt 0 phases

        phase_1 =
            Maybe.withDefault 0 <| getAt 1 phases

        phase_2 =
            Maybe.withDefault 0 <| getAt 2 phases

        phase_3 =
            Maybe.withDefault 0 <| getAt 3 phases
    in
    vec4 phase_0 phase_1 phase_2 phase_3


createAmplitudeVec : List Cosine -> Vec4
createAmplitudeVec cosines =
    let
        amplitudes =
            List.map (\x -> x.amplitude) cosines

        amplitude_0 =
            Maybe.withDefault 0 <| getAt 0 amplitudes

        amplitude_1 =
            Maybe.withDefault 0 <| getAt 1 amplitudes

        amplitude_2 =
            Maybe.withDefault 0 <| getAt 2 amplitudes

        amplitude_3 =
            Maybe.withDefault 0 <| getAt 3 amplitudes
    in
    vec4 amplitude_0 amplitude_1 amplitude_2 amplitude_3


createFrequencyVec : List Cosine -> Vec4
createFrequencyVec cosines =
    let
        frequencies =
            List.map (\x -> x.frequency) cosines

        frequency_0 =
            Maybe.withDefault 0 <| getAt 0 frequencies

        frequency_1 =
            Maybe.withDefault 0 <| getAt 1 frequencies

        frequency_2 =
            Maybe.withDefault 0 <| getAt 2 frequencies

        frequency_3 =
            Maybe.withDefault 0 <| getAt 3 frequencies
    in
    vec4 frequency_0 frequency_1 frequency_2 frequency_3


createOffsetVec : List Cosine -> Vec4
createOffsetVec cosines =
    let
        offsets =
            List.map (\x -> x.offset) cosines

        offset_0 =
            Maybe.withDefault 0 <| getAt 0 offsets

        offset_1 =
            Maybe.withDefault 0 <| getAt 1 offsets

        offset_2 =
            Maybe.withDefault 0 <| getAt 2 offsets

        offset_3 =
            Maybe.withDefault 0 <| getAt 3 offsets
    in
    vec4 offset_0 offset_1 offset_2 offset_3



-- WebGL stuff


type alias Vertex =
    { position : Vec2.Vec2
    }


type alias Uniforms =
    { resolution : Vec2.Vec2
    , phase : Vec4.Vec4
    , amplitude : Vec4.Vec4
    , frequency : Vec4.Vec4
    , offset : Vec4.Vec4
    }


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


gradientShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
gradientShader =
    [glsl|
    precision mediump float;
    uniform vec2 resolution;
    uniform vec4 phase;
    uniform vec4 amplitude;
    uniform vec4 frequency;
    uniform vec4 offset;

    varying vec3 vcolor;

    vec4 cosine_gradient(float x,  vec4 phase, vec4 amp, vec4 freq, vec4 offset){
      phase *= 3.14159265 * 2.;
      x *= 3.14159265 * 2.;

      return vec4(
        (offset.r) + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
        (offset.g) + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
        (offset.b) + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
        (offset.a) + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
        );
    }


    void main(){
      vec2 p = (gl_FragCoord.xy * 2. - resolution) / min(resolution.x, resolution.y);
      vec2 uv = gl_FragCoord.xy / resolution;
      vec4 color = vec4(cosine_gradient(uv.x, phase, amplitude, frequency, offset).rgb, 1.0);

      gl_FragColor = color;
    }
    |]


graphShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
graphShader =
    [glsl|
    precision mediump float;
    uniform vec2 resolution;
    uniform vec4 phase;
    uniform vec4 amplitude;
    uniform vec4 frequency;
    uniform vec4 offset;

    varying vec3 vcolor;
    const float TAU = 2. * 3.14159265;

    // https://thebookofshaders.com/05/
    float plot(vec2 st, float value){
      return  smoothstep( value-0.0075, value, st.y) -
          smoothstep( value, value+0.0075, st.y);
    }

    vec4 cosine_gradient(float x,  vec4 phase, vec4 amp, vec4 freq, vec4 offset){
      phase *= 3.14159265 * 2.;
      x *= 3.14159265 * 2.;

      return vec4(
        (offset.r) + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
        (offset.g) + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
        (offset.b) + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
        (offset.a) + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
        );
    }

    void main(){
      vec2 p = (gl_FragCoord.xy * 2. - resolution) / min(resolution.x, resolution.y);
      vec2 uv = gl_FragCoord.xy / resolution;
      vec2 st = vec2(gl_FragCoord.x / resolution.x, (gl_FragCoord.y * 2. - resolution.y) / resolution.y);
      vec4 color = vec4(abs(st), .75, 1.);

      vec4 cos_grad = cosine_gradient(uv.x, phase, amplitude, frequency, offset);
      cos_grad = clamp(cos_grad, 0., 1.);

      float plotted_r = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.r);
      float plotted_g = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.g);
      float plotted_b = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.b);

      color = vec4(.95);
      color -= plotted_r*vec4(0., 1., 1., 0.);
      color -= plotted_g*vec4(1., 0., 1., 0.);
      color -= plotted_b*vec4(1., 1., 0., 0.);

      gl_FragColor = color;
    }
  |]
