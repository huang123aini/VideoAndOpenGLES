precision mediump float;

varying highp vec2 vTexCoord;

uniform sampler2D  uSampler;

uniform float uTime;

//void main()
//{
//    gl_FragColor = texture2D(uSampler, vTexCoord.xy);
//    
//}

void main(void)
{
    
    vec2 uv = vTexCoord;
    
    uv.y += (cos((uv.y + (uTime * 0.04)) * 45.0) * 0.0019) +
    (cos((uv.y + (uTime * 0.1)) * 10.0) * 0.002);
    
    uv.x += (sin((uv.y + (uTime * 0.07)) * 15.0) * 0.0029) +
    (sin((uv.y + (uTime * 0.1)) * 15.0) * 0.002);
    
    gl_FragColor = texture2D(uSampler, uv);
}
