precision mediump float;

//varying highp vec2 vTexCoord;

//uniform sampler2D  uSampler;

uniform float      uTime;



float SmoothBump (float lo, float hi, float w, float x);
vec3 HsvToRgb (vec3 c);
float Hashfv2 (vec2 p);
vec2 Hashv2v2 (vec2 p);

vec2 gVec[7], hVec[7];
float tCur;
const float pi = 3.14159;

#define SQRT3 1.7320508

vec2 PixToHex (vec2 p)
{
    vec3 c, r, dr;
    c.xz = vec2 ((1./SQRT3) * p.x - (1./3.) * p.y, (2./3.) * p.y);
    c.y = - c.x - c.z;
    r = floor (c + 0.5);
    dr = abs (r - c);
    r -= step (dr.yzx, dr) * step (dr.zxy, dr) * dot (r, vec3 (1.));
    return r.xz;
}

vec2 HexToPix (vec2 h)
{
    return vec2 (SQRT3 * (h.x + 0.5 * h.y), (3./2.) * h.y);
}

float HexEdgeDist (vec2 p)
{
    p = abs (p);
    return (SQRT3/2.) - p.x + 0.5 * min (p.x - SQRT3 * p.y, 0.);
}

void HexVorInit ()
{
    vec3 e = vec3 (1., 0., -1.);
    gVec[0] = e.yy;
    gVec[1] = e.xy;
    gVec[2] = e.yx;
    gVec[3] = e.xz;
    gVec[4] = e.zy;
    gVec[5] = e.yz;
    gVec[6] = e.zx;
    for (int k = 0; k < 7; k ++) hVec[k] = HexToPix (gVec[k]);
}

vec4 HexVor (vec2 p)
{
    vec4 udm;
    vec3 sd;
    vec2 ip, fp, d, u;
    float amp, a;
    bool nNew;
    amp = 0.7;
    ip = PixToHex (p);
    fp = p - HexToPix (ip);
    sd = vec3 (4.);
    udm = vec4 (0.);
    for (int k = 0; k < 7; k ++)
    {
        u = Hashv2v2 (ip + gVec[k]);
        a = 2. * pi * (u.y - 0.5) * tCur;
        d = hVec[k] + amp * (0.4 + 0.6 * u.x) * vec2 (cos (a), sin (a)) - fp;
        sd.z = dot (d, d);
        nNew = (sd.z < sd.x);
        udm = nNew ? vec4 (d, u) : udm;
        sd = nNew ? sd.zxz : ((sd.z < sd.y) ? sd.xzz : sd);
    }
    sd.xy = sqrt (sd.xy);
    return vec4 (sd.y - sd.x, udm.xy, Hashfv2 (udm.zw));
}

vec3 ShowScene (vec2 p)
{
    vec4 vc;
    vec3 col;
    vec2 dp;
    float dm, s, tCyc;
    HexVorInit ();
    col = vec3 (0.);
    tCyc = mod (0.02 * tCur, 1.);
    vc = HexVor (p);
    col = mix (vec3 (0.5, 1., 0.5), HsvToRgb (vec3 (mod (vc.w, 1.), 0.7, 1.)),
               SmoothBump (0.2, 0.7, 0.02, mod (tCyc, 1.)));
    dm = length (vc.yz);
    col *= (1. - min (0.8 * dm, 1.)) * mix (1., 0.7 + 0.3 * sin (40. * vc.x),
                                            SmoothBump (0.2, 0.7, 0.02, mod (2. * tCyc, 1.)));
    s = SmoothBump (0.2, 0.7, 0.02, mod (4. * tCyc, 1.));
    col = mix (vec3 (1., 0.5, 0.), col,
               min (min (s + smoothstep (0.03, 0.04, vc.x), 1.),
                    min (s + smoothstep (0.05, 0.1, dm), 1.)));
    s = SmoothBump (0.1, 0.9, 0.01, mod (8. * tCyc, 1.));
    dp = p - HexToPix (PixToHex (p));
    col = mix (vec3 (0.3, 0.3, 0.7), col,
               min (min (s + smoothstep (0.02, 0.03, HexEdgeDist (dp)), 1.),
                    min (s + smoothstep (0.04, 0.06, length (dp)), 1.)));
    return col;
}

void main(void)
{
    vec2 spriteSize = vec2(480,640);
    vec3 col;
    vec2 canvas, uv, p;
    float pSize;
    canvas = spriteSize.xy;
    uv = 2. * gl_FragCoord.xy / canvas - 1.;
    uv.x *= canvas.x / canvas.y;
    tCur = uTime;
    tCur += 20.;
    pSize = canvas.x / 100.;
    p = pSize * uv;
    gl_FragColor = vec4 (ShowScene (p), 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
    return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec3 HsvToRgb (vec3 c)
{
    vec3 p;
    p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
    return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashfv2 (vec2 p)
{
    return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

vec2 Hashv2v2 (vec2 p)
{
    const vec2 cHashVA2 = vec2 (37.1, 61.7);
    const vec2 e = vec2 (1., 0.);
    return fract (sin (vec2 (dot (p + e.yy, cHashVA2),
                             dot (p + e.xy, cHashVA2))) * cHashM);
}

