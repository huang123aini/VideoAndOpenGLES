
attribute vec3 position;
attribute vec2 inputTextureCoordinate;
varying   vec2 textureCoordinate;
uniform   mat4 u_mvpMatrix;
void main()
{
    gl_Position =u_mvpMatrix*vec4(position,1.0);
    
    textureCoordinate = inputTextureCoordinate.xy;
}
