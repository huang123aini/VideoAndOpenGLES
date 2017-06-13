precision mediump float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    
    vec4 color=texture2D(inputImageTexture, textureCoordinate.xy);
    gl_FragColor =vec4(color.rgb,0.8);
    
}
