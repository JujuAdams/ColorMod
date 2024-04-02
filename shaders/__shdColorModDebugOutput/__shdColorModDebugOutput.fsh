varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_fColumn;
uniform float u_fRow;
uniform vec2  u_vTexel;

void main()
{
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, u_vTexel*vec2(u_fColumn + 0.5, u_fRow + 0.5));
}