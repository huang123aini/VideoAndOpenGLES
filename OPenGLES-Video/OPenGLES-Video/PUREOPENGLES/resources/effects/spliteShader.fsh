precision mediump float;

varying highp vec2 vTexCoord;

//uniform sampler2D  uSampler;

uniform float      uTime;

#define PI 3.14159265359

float fft(vec2 uv)
{
    return cos( uv.y * PI * (2.0 * uv.x + 1.0) / 16.0 );
}

void main()
{

    vec2 spriteSize = vec2(750,1334);
    
    float ZOOM = 2.0;
    
    float SIZE = (ZOOM*2.0) * 8.0; // Sub-divide into 8x8: 0 .. 7
    
    vec2  uv = floor( (SIZE * gl_FragCoord.xy) / spriteSize.xy );
    
    vec2  st = vec2( floor( uv * 8.0 ) / 8.0);

    float y  = (1.0 + fft( uv )) * 0.5;
    
    vec3  color   = vec3( y ); // TODO: Gamma correct
    
    
    gl_FragColor = vec4(color,1.0);
}
