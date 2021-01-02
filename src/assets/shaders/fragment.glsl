// #define PI 3.141592653589793238;
// #define RM_ACCURACY .001;
// #define RM_MAX_DISTANCE 5.;

const float PI=3.141592653589793238;
const float RM_ACCURACY=.0001;
const float RM_MAX_DISTANCE=5.;

uniform float uTime;
uniform vec2 uResolution;
varying vec2 vUv;

/*
* SDFs
*/
float sdSphere(vec3 point,float radius){
    return length(point)-radius;
}
/*
* SDFs, end
*/

// Scene definition happens here
vec2 map(vec3 point,float time){
    float sdfId=1.;
    return vec2(sdSphere(point,.01),sdfId);
}

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
    vec3 cameraPosition=vec3(0.,0.,2.);
    vec3 rayDirection=normalize(vec3(displayUV,-1.));
    vec2 raymarchResult=castRay(cameraPosition,rayDirection,uTime);

    // Colouring
    // Background
    vec3 colour=mix(vec3(.2),vec3(0.),length(vUv-vec2(.5)));

    // Check what sdfId the raymarchResult returns, e.g. raymarchResult.y>.5 means that we hit id 0
    if(raymarchResult.y>.5){
        colour=vec3(1.);
    }

    // Results
    gl_FragColor=vec4(colour,1.);
}
