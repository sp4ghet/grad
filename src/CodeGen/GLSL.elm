module CodeGen.GLSL exposing (render)

import Common.Helper exposing (float2string)
import String exposing (fromFloat)
import Types exposing (ColorSpace(..), Cosine)


render : ColorSpace -> List Cosine -> String
render colorSpace cosines =
    let
        phases =
            createPhases cosines

        amplitudes =
            createAmplitude cosines

        frequencies =
            createFrequency cosines

        offsets =
            createOffset cosines

        toRGB =
            createToRGB colorSpace
    in
    """
precision mediump float;
uniform vec2 resolution;
"""
        ++ phases
        ++ amplitudes
        ++ frequencies
        ++ offsets
        ++ """
const float TAU = 2. * 3.14159265;

vec4 cosine_gradient(float x,  vec4 phase, vec4 amp, vec4 freq, vec4 offset){
  phase *= TAU;
  x *= TAU;

  return vec4(
    offset.r + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
    offset.g + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
    offset.b + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
    offset.a + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
  );
}
"""
        ++ toRGB
        ++ """
void main(){
  vec2 uv = gl_FragCoord.xy / resolution;
  vec4 cos_grad = cosine_gradient(uv.x, phases, amplitudes, frequencies, offsets);
  cos_grad = clamp(cos_grad, 0., 1.);

  vec4 color = vec4(toRGB(cos_grad), 1.0);

  gl_FragColor = color;
}
"""


createToRGB : ColorSpace -> String
createToRGB colorSpace =
    case colorSpace of
        RGB ->
            """
vec3 toRGB(vec4 grad){
  return grad.rgb;
}
          """

        HSV ->
            """
vec3 toRGB(vec4 grad){
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(grad.xxx + K.xyz) * 6.0 - K.www);
  return grad.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), grad.y);
}
          """

        _ ->
            ""


createPhases : List Cosine -> String
createPhases cosines =
    let
        phases =
            List.map (\x -> float2string x.phase) cosines

        padded_phases =
            List.take 4 <| phases ++ [ "0.", "0.", "0.", "0." ]

        phase_str =
            List.foldr (++) "" <| List.intersperse ", " padded_phases
    in
    "const vec4 phases = vec4(" ++ phase_str ++ ");\n"


createAmplitude : List Cosine -> String
createAmplitude cosines =
    let
        amplitudes =
            List.map (\x -> float2string x.amplitude) cosines

        padded_amplitudes =
            List.take 4 <| amplitudes ++ [ "0.", "0.", "0.", "0." ]

        amplitude_str =
            List.foldr (++) "" <| List.intersperse ", " padded_amplitudes
    in
    "const vec4 amplitudes = vec4(" ++ amplitude_str ++ ");\n"


createFrequency : List Cosine -> String
createFrequency cosines =
    let
        frequencies =
            List.map (\x -> float2string x.frequency) cosines

        padded_frequencies =
            List.take 4 <| frequencies ++ [ "0.", "0.", "0.", "0." ]

        frequency_str =
            List.foldr (++) "" <| List.intersperse ", " padded_frequencies
    in
    "const vec4 frequencies = vec4(" ++ frequency_str ++ ");\n"


createOffset : List Cosine -> String
createOffset cosines =
    let
        offsets =
            List.map (\x -> float2string x.offset) cosines

        padded_offsets =
            List.take 4 <| offsets ++ [ "0.", "0.", "0.", "0." ]

        offset_str =
            List.foldr (++) "" <| List.intersperse ", " padded_offsets
    in
    "const vec4 offsets = vec4(" ++ offset_str ++ ");\n"
