import * as THREE from 'three';

import '../sass/index.sass';
import fragment from '../assets/shaders/fragment.glsl';
import vertex from '../assets/shaders/vertex.glsl';

/*
 * Declarations
 */
// Constants
const frustumSize = 1;

// Variables
let camera; let scene; let renderer; let rootContainer; let material;
let time = 0;


function init() {
    /* Setup THREE boilerplate */
    rootContainer = document.querySelector('.root');

    const { w, h, resolution } = getProportions();

    scene = new THREE.Scene();

    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(w, h);

    rootContainer.appendChild(renderer.domElement);

    camera = new THREE.OrthographicCamera(frustumSize / - 2, frustumSize / 2, frustumSize / 2, frustumSize / - 2, -1000, 1000);
    camera.position.set(0, 0, 2);

    /* Start custom stuff */
    material = new THREE.ShaderMaterial({
        extensions: {
            derivatives: '#extension GL_OES_standard_derivatives : enable'
        },
        side: THREE.DoubleSide,
        uniforms: {
            uTime: { value: 0 },
            uResolution: { value: resolution }
        },
        vertexShader: vertex,
        fragmentShader: fragment,
    });

    const planeGeometry = new THREE.PlaneBufferGeometry(1, 1, 1, 1);
    const plane = new THREE.Mesh(planeGeometry, material);
    scene.add(plane);

    resize();
    window.addEventListener('resize', resize);
}

function animate() {
    time += 0.05;
    material.uniforms.uTime.value = time;

    requestAnimationFrame(animate);
    render();
}

function render() {
    renderer.render(scene, camera);
}

/*
 * Helper functions and event listeners
 */
function getProportions() {
    const w = rootContainer.offsetWidth;
    const h = rootContainer.offsetHeight;
    const a1 = (h > w) ? (w / h) : 1;
    const a2 = (h > w) ? 1 : (h / w);
    const resolution = new THREE.Vector2(a1, a2);

    return { w, h, resolution };
}

function resize() {
    const { w, h, resolution } = getProportions();

    material.uniforms.uResolution.value = resolution;
    renderer.setSize(w, h);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
}


/*
 * Calls
 */
init();
animate();
