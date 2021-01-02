#define PI 3.141592653589793238;

uniform float time;
uniform vec2 resolution;
varying vec2 vUv;


void main()	{
    // UV of display grid
	vec2 displayUV = (vUv - vec2(0.5))*resolution;

    vec3 color = vec3(step(0.1,length(displayUV)));

	gl_FragColor = vec4(color, 1.);
}
