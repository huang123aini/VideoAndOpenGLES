precision mediump float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform float opaticy;//opaticy,0.0~1.0

void main()
{
    float fixedOpaticy=opaticy;
    
    if(fixedOpaticy<0.0)fixedOpaticy=0.0;
    
    if(fixedOpaticy>1.0)fixedOpaticy=1.0;
    
    vec4 color =texture2D(inputImageTexture, textureCoordinate.xy);
    
    gl_FragColor=color*fixedOpaticy;
    
}
