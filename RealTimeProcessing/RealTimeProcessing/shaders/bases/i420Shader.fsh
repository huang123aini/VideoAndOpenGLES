uniform sampler2D SamplerY;
uniform sampler2D SamplerU;
uniform sampler2D SamplerV;

varying highp vec2 textureCoordinate;

uniform lowp int isFullRange;

uniform lowp int isBT709;

void main()
{
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    if(isFullRange==1)
    {
        yuv.x = texture2D(SamplerY, textureCoordinate).r;
        
    }else
    {
        yuv.x = texture2D(SamplerY, textureCoordinate).r - (16.0/255.0);
    }
    
    yuv.y = texture2D(SamplerU, textureCoordinate).r - 0.5;
    yuv.z = texture2D(SamplerV, textureCoordinate).r - 0.5;
    
    if(isBT709==1)
    {
        
        rgb=mat3( 1.164,  1.164, 1.164,
                 0.0, -0.213, 2.112,
                 1.793, -0.533,   0.0)*yuv;
    }else
    {
        
        rgb=mat3( 1.0,    1.0,    1.0,
                 0.0,    -0.343, 1.765,
                 1.4,    -0.711, 0.0)*yuv;
        
    }
    
    gl_FragColor = vec4(rgb, 1);
}
