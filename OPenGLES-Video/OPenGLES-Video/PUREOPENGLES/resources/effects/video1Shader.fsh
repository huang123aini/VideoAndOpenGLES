precision mediump float;

varying highp vec2 vTexCoord;

uniform sampler2D  uSampler;

uniform float      uTime;

#define nrows 100.
#define ncols 100.

//#define spriteSize  vec2(750,1334)

#define MIX_COLOR false

float luminosity(vec4 col)
{
    return 0.21 * col.r + 0.72 * col.g + 0.07 * col.b;
}

vec2 getTileSize()
{
    
    vec2 spriteSize = vec2(750,1334);
    float tw = spriteSize.x / nrows;
    float th = spriteSize.y / ncols;
    
    th *= (spriteSize.x / spriteSize.y);
    
    return vec2(tw, th);
}

// Returns tile coordinates between [0, 0] and [nrows-1, ncols-1]
vec2 getCoord(vec2 coord)
{
    vec2 ts = getTileSize();
    
    int row = int(floor(coord.x / ts.x));
    int col = int(floor(coord.y / ts.y));
    
    return vec2(row, col);
}

float sampleTile(vec2 coord)
{
    vec2 ts = getTileSize();
    
    float dx = ts.x / 4.;
    float dy = ts.y / 4.;
    
    float startx = (coord.x * ts.x) + 0.5 * dx;
    float starty = (coord.y * ts.y) + 0.5 * dy;
    
    float sum = 0.;
    
    vec2 spriteSize = vec2(750,1334);
    
    
    for(int i = 0; i < 4; i++)
    {
        float x = startx + float(i) * dx;
        
        for(int j = 0; j < 4; j++)
        {
            float y = starty + float(j) * dy;
            
            vec2 coord = vec2(x, y) / spriteSize.xy;
            
            vec4 col = texture2D(uSampler, coord);
            
            float l = luminosity(col);
            
            sum += l;
        }
    }
    
    return sum / 16.;
}


vec4 makeLum(float f)
{
    return vec4(vec3(f), 1.);
}

vec4 grid(vec2 coord)
{
    vec2 tileCoord = getCoord(coord);
    
    if (mod(tileCoord.x, 2.) == mod(tileCoord.y, 2.))
    {
        return vec4(1);
    }
    
    else
    {
        return vec4(vec3(0), 1);
    }
}

vec4 tileCircle(vec2 tileCoord, vec2 windowCoord, float lum)
{
    // First, get center of circle for this tile
    vec2 tileSize = getTileSize();
    
    vec2 tileStart = tileCoord * tileSize;
    
    vec2 circleCenter = tileStart + 0.5 * tileSize;
    
    //float circleRadius = length(tileSize) * (iResolution.y / iResolution.x) * 0.5;
    float circleRadius = length(tileSize) * 0.5;
    
    circleRadius *= lum;
    
    float d = length(windowCoord - circleCenter);
    
    if (d < circleRadius)
    {
        return vec4(vec3(1), 1.0);
    }
    else
    {
        return vec4(0);
    }
}

vec4 comicShader(vec2 coord)
{
    vec2 spriteSize = vec2(750,1334);
    
    vec2 uv = coord / spriteSize.xy;
    
    // Get tile coord
    vec2 tileCoord = getCoord(coord);
    
    // Sample colors from tile
    float lum = sampleTile(tileCoord);
    
    return tileCircle(tileCoord, coord, lum);
}

vec4 normalShader(vec2 uv)
{
    return texture2D(uSampler, uv);
}

void main(void)
{
    
    vec2 spriteSize = vec2(750,1334);
    vec2 coord = gl_FragCoord.xy;
    vec2 uv = gl_FragCoord.xy / spriteSize.xy;
    
    vec4 col = comicShader(coord);
    
    if (MIX_COLOR)
    {
        col = col * normalShader(uv);
    }
    
    gl_FragColor = col;
}
