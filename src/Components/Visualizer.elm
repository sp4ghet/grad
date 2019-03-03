module Components.Visualizer exposing (gradient, graph)

import Common.Helper exposing (combineCosineParams, convertToRGB)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import List.Extra as ListX exposing (getAt)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import Types exposing (ColorSpace(..), Cosine, Model, Msg(..))
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

        colorSpace =
            colorSpaceToIntId model.colorSpace
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
                , colorSpace = colorSpace
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

        colorSpace =
            colorSpaceToIntId model.colorSpace
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
                , colorSpace = colorSpace
                }
            ]
        ]



-- Helpers


colorSpaceToIntId : ColorSpace -> Int
colorSpaceToIntId colorSpace =
    case colorSpace of
        RGB ->
            0

        HSV ->
            1

        CMYK ->
            2

        XYZ ->
            3


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
    , colorSpace : Int
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
    uniform int colorSpace;

    varying vec3 vcolor;

    const int RGB = 0;
    const int HSV = 1;
    const int CMYK = 2;
    const int XYZ = 3;

    const float TAU = 2. * 3.14159265;

    vec4 cosine_gradient(float x,  vec4 phase, vec4 amp, vec4 freq, vec4 offset){
      phase *= TAU;
      x *= TAU;

      return vec4(
        (offset.r) + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
        (offset.g) + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
        (offset.b) + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
        (offset.a) + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
        );
    }

    vec3 hsv2rgb(vec3 c) {
      vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
      vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
      return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec3 gradientToRGB(vec4 cos_grad){
      if(colorSpace == RGB){
        return cos_grad.rgb;
      }
      if(colorSpace == HSV){
        return hsv2rgb(cos_grad.rgb);
      }
      if(colorSpace == CMYK){

      }
      if(colorSpace == XYZ){

      }
      return cos_grad.rgb;
    }

    void main(){
      vec2 p = (gl_FragCoord.xy * 2. - resolution) / min(resolution.x, resolution.y);
      vec2 uv = gl_FragCoord.xy / resolution;
      vec4 cos_grad = cosine_gradient(uv.x, phase, amplitude, frequency, offset);
      cos_grad = clamp(cos_grad, 0., 1.);

      vec4 color = vec4(gradientToRGB(cos_grad), 1.0);

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
    uniform int colorSpace;

    varying vec3 vcolor;

    const int RGB = 0;
    const int HSV = 1;
    const int CMYK = 2;
    const int XYZ = 3;

    const float TAU = 2. * 3.14159265;

    // https://thebookofshaders.com/05/
    float plot(vec2 st, float value){
      return  smoothstep( value-0.0075, value, st.y) -
          smoothstep( value, value+0.0075, st.y);
    }

    vec4 cosine_gradient(float x,  vec4 phase, vec4 amp, vec4 freq, vec4 offset){
      phase *= TAU;
      x *= TAU;

      return vec4(
        (offset.r) + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
        (offset.g) + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
        (offset.b) + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
        (offset.a) + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
        );
    }

    vec3 hsv2rgb(vec3 c) {
      vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
      vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
      return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec4 plotToRGB(vec2 uv, vec4 plot){
      vec4 color = vec4(.95);
      vec2 bw = vec2(0., 1.);
      if(colorSpace == RGB){
          color -= plot.r * bw.xyyx;
          color -= plot.g * bw.yxyx;
          color -= plot.b * bw.yyxx;
        return color;
      }
      if(colorSpace == HSV){
        vec3 neg_hue = vec3(1.) - hsv2rgb(vec3(uv.y, 1., 1.));
        vec3 neg_sat = vec3(1.) - hsv2rgb(vec3(uv.x, uv.y, 0.75));
        vec3 neg_val = vec3(1.) - hsv2rgb(vec3(uv.x, 0.5, uv.y));
        color -= plot.x * vec4(neg_hue, 0.);
        color -= plot.y * vec4(neg_sat, 0.);
        color -= plot.z * vec4(neg_val, 1.);
        return color;
      }
      if(colorSpace == CMYK){

      }
      if(colorSpace == XYZ){

      }
      return color;
    }

    void main(){
      vec2 p = (gl_FragCoord.xy * 2. - resolution) / min(resolution.x, resolution.y);
      vec2 uv = gl_FragCoord.xy / resolution;
      vec2 st = vec2(gl_FragCoord.x / resolution.x, (gl_FragCoord.y * 2. - resolution.y) / resolution.y);
      vec4 color = vec4(abs(st), .75, 1.);

      vec4 cos_grad = cosine_gradient(uv.x, phase, amplitude, frequency, offset);
      cos_grad = clamp(cos_grad, 0., 1.);

      vec4 plotted = vec4(0.);
      plotted.x = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.x);
      plotted.y = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.y);
      plotted.z = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.z);
      plotted.w = plot(uv * vec2(1., 1.1) - 0.05, cos_grad.w);

      color = plotToRGB(uv, plotted);

      gl_FragColor = color;
    }
  |]
