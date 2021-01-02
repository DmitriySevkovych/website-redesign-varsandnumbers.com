// #define PI 3.141592653589793238;
// #define RM_ACCURACY .001;
// #define RM_MAX_DISTANCE 5.;

const float PI=3.141592653589793238;
const float RM_ACCURACY=.001;
const float RM_MAX_DISTANCE=50.;

uniform float uTime;
uniform float uSminK;
uniform vec2 uResolution;
varying vec2 vUv;

vec2 map(vec3 point,float time);

/*
* Helpers
*/
vec3 calcNormal( vec3 point, float time )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.001;
    return normalize( e.xyy*map( point + e.xyy, time ).x +
    e.yyx*map( point + e.yyx, time ).x +
    e.yxy*map( point + e.yxy, time ).x +
    e.xxx*map( point + e.xxx, time ).x );
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}
/*
* Helpers, end
*/

/*
* SDFs
*/
float sdSphere(vec3 point,float radius){
    return length(point)-radius;
}

vec2 sdStick(vec3 point, vec3 a, vec3 b, float r1, float r2) // approximated
{
    vec3 pa = point-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return vec2( length( pa - ba*h ) - mix(r1,r2,h*h*(3.0-2.0*h)), h );
}

// Scene definition happens here
vec2 map(vec3 point,float time){
    float distScene = -1.;
    float sdfId=-1.;

    // first sphere
    float sphereRadius = 1.;
    float distSphere = sdSphere(point,sphereRadius);
    distScene = distSphere;
    sdfId = 1.;

    // first stick
    vec3 stickStart = vec3(-5.,0.,0.);
    vec3 stickEnd = vec3(0.,0.,-sphereRadius);
    float distStick = sdStick(point,stickStart, stickEnd, 0.01,0.05).x;
    sdfId = distStick < distScene ? 2. : sdfId;
    distScene = smin(distScene, distStick, uSminK);

    return vec2(distScene,sdfId);
}
/*
* SDFs, end
*/

// Raymarching happens here
// returns vector with (distance to scene, id of closest sdf)
vec2 castRay(vec3 rayOrigin,vec3 rayDirection,float time){

    // TODO add raytracing + bounding boxes for optimization

    // raymarching
    vec2 result=vec2(-1.,-1.);
    float marchedDistance=0.;

    for(int i=0;i<256&&marchedDistance<RM_MAX_DISTANCE;i++)
    {
        vec2 marchResult=map(rayOrigin+rayDirection*marchedDistance,time);
        if(abs(marchResult.x)<(RM_ACCURACY*marchedDistance))
        {
            result=vec2(marchedDistance,marchResult.y);
            break;
        }
        marchedDistance+=marchResult.x;
    }

    return result;
}

void main(){
    // Raymarching
    // UV of display grid
    vec2 displayUV=(vUv-vec2(.5))*uResolution;
    vec3 cameraPosition=vec3(0.,0.,10.);
    vec3 rayDirection=normalize(vec3(displayUV,-1.));
    vec2 raymarchResult=castRay(cameraPosition,rayDirection,uTime);

    // Colouring
    // Background
    vec3 colour=mix(vec3(.2),vec3(0.),length(vUv-vec2(.5)));

    // Check what sdfId the raymarchResult returns, e.g. raymarchResult.y>.5 means that we hit id 0
    if(raymarchResult.y>1.5){
        vec3 normal=calcNormal(rayDirection*raymarchResult.x+cameraPosition,uTime);
        colour=vec3(1.,1.,0.);
    }else if(raymarchResult.y>.5){
        vec3 normal=calcNormal(rayDirection*raymarchResult.x+cameraPosition,uTime);
        colour=vec3(dot(vec3(1.),normal));
    }

    // Results
    gl_FragColor=vec4(colour,1.);
}
