// #define PI 3.141592653589793238;
// #define RM_ACCURACY .001;
// #define RM_MAX_DISTANCE 5.;

const float PI=3.141592653589793238;
const float TAU=2.*PI;
const float RM_ACCURACY=.0001;
const float RM_MAX_DISTANCE=50.;
const int NUM_STICKS=5;

uniform float uTime;
uniform float uSminK;
uniform vec2 uResolution;
uniform vec2 uAnimations[NUM_STICKS];

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

float getSphereAnimation(vec2 animations[NUM_STICKS]) {
    float result = 0.;
    for(int i = 0; i < NUM_STICKS; i++) {
        result += animations[i].y;
    }
    return result;
}

vec3 getSphereDirection(vec3 directions[NUM_STICKS], vec2 animations[NUM_STICKS]) {
    // starting direction
    vec3 sphereDirection = directions[0] * (1. - step(1.,animations[0].y));
    // add layers of directions
    for(int i = 1; i < NUM_STICKS-1; i++) {
        sphereDirection += directions[i]
                            * (1. - step(1.,uAnimations[i].y))
                            * step(1.,uAnimations[i-1].y);
    }
    sphereDirection += directions[NUM_STICKS-1] * step(1.,animations[NUM_STICKS-2].y);
    return sphereDirection;
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

float sdUnion(vec3 point, vec3 direction, float animation) {
    vec3 stickStart = 5.*direction;
    vec3 stickEnd = 5.*(1.-animation)*direction;
    return sdStick(point,stickStart, stickEnd, 0.01,0.05).x;
}


// Scene definition happens here
vec2 map(vec3 point,float time){
    float distScene = -1.;
    float sdfId=-1.;

    vec3 directions[NUM_STICKS];
    directions[0]= normalize(vec3(-1.,1.,-1.));
    directions[1]= normalize(vec3(1.,0.,2.));
    directions[2]= normalize(vec3(-0.2,-2.,3.));
    directions[3]= normalize(vec3(-3.,-2.,-3.));
    directions[4]= normalize(vec3(2.,5.,0.));
    // sphere
    {
        float sphereRadius = 0.5;
        float animation = fract(getSphereAnimation(uAnimations));
        float parabola = 4.*animation*(1.-animation);
        vec3 direction = getSphereDirection(directions,uAnimations);

        // shift sphere when hit by stick
        vec3 shiftOnImpact = direction * parabola;
        vec3 spherePoint = point + shiftOnImpact;
        float distSphere = sdSphere(spherePoint,sphereRadius);

        // impact waves on sphere
        vec3 impactEpicentre = -1.*sphereRadius*normalize(direction);
        vec3 impactPoint = spherePoint - impactEpicentre;
        // float impactPoint = spherePoint.x+sphereRadius-animation;
        float impactArea = smoothstep(0.,sphereRadius,length(impactPoint));

        float impact = 0.06*sin(3.*TAU*(length(impactPoint) -time/4.) );
        distSphere += impact * impactArea * parabola;

        // result
        distScene = distSphere;
        sdfId = 1.;
    }

    // sticks
    for(int i = 0; i < NUM_STICKS; i++) {
        float distStick = sdUnion(point, directions[i], uAnimations[i].x);
        sdfId = distStick < distScene ? 2. : sdfId;
        distScene = smin(distScene, distStick, uSminK);
    }

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
    vec3 bgColour=mix(vec3(.2),vec3(0.),length(vUv-vec2(.5)));
    if(raymarchResult.y<0.){
        gl_FragColor=vec4(bgColour,1.);
        return;
    }

    vec3 normal=calcNormal(rayDirection*raymarchResult.x+cameraPosition,uTime);
    vec3 colour=vec3(dot(vec3(1.),normal));
    float fresnel=pow(1.+dot(rayDirection,normal),3.);
    colour=mix(colour,bgColour,fresnel);

    // Check what sdfId the raymarchResult returns, e.g. raymarchResult.y>.5 means that we hit id 0
    // if(raymarchResult.y>1.5){
        //     colour=vec3(dot(vec3(1.),normal));
    // }else if(raymarchResult.y>.5){
        //     colour=vec3(dot(vec3(1.),normal));
    // }

    // Results
    gl_FragColor=vec4(colour,1./raymarchResult.y);
}
