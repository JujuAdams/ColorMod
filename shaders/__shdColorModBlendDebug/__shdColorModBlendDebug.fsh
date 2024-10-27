precision highp float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_sPalette;
uniform vec3  u_vColumnData;
uniform vec4  u_vModulo;
uniform vec2  u_vTexel;

//Special integer modulo function because GLSE ES 1.00 doesn't have it
float modI(float a, float b)
{
    float m = a - b*floor((a + 0.5) / b);
    return floor(m + 0.5);
}

vec3 modV(vec3 a, float b)
{
    vec3 m = a - b*floor((a + 0.5) / b);
    return floor(m + 0.5);
}

void main()
{
    vec4 inputSample = texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 moduloVector = u_vModulo.rgb*modV(255.0*inputSample.rgb, u_vModulo.a);
    float moduloValue = mod(moduloVector.r + moduloVector.g + moduloVector.b, u_vModulo.a);
    
    vec4 testSample = texture2D(u_sPalette, u_vTexel*vec2(0.5, moduloValue + 0.5));
    if (all(equal(testSample.rgb, inputSample.rgb)))
    {
        vec4 outputSample = mix(texture2D(u_sPalette, u_vTexel*vec2(u_vColumnData.x + 0.5, moduloValue + 0.5)),
                                texture2D(u_sPalette, u_vTexel*vec2(u_vColumnData.y + 0.5, moduloValue + 0.5)),
                                u_vColumnData.z);
        
        gl_FragColor.rgb = v_vColour.rgb * mix(inputSample.rgb, outputSample.rgb, outputSample.a);
        gl_FragColor.a   = v_vColour.a * inputSample.a;
    }
    else
    {
        gl_FragColor = vec4(1.0, 0.0, 1.0, inputSample.a);
    }
}