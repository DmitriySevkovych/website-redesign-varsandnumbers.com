import * as THREE from 'three';
// let OrbitControls = require('three-orbit-controls')(THREE);

import '../sass/index.sass';
import fragment from '../assets/shaders/fragment.glsl';
import vertex from '../assets/shaders/vertex.glsl';

/*
 * Declarations
 */
// Constants

// Variables
let camera; let scene; let renderer; let rootContainer; let material;
let time = 0;


function init() {
    /* Setup THREE boilerplate */
    rootContainer = document.querySelector('.root');
    const w = rootContainer.offsetWidth;
    const h = rootContainer.offsetHeight;

    scene = new THREE.Scene();

    renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(w, h);

    rootContainer.appendChild(renderer.domElement);

    camera = new THREE.PerspectiveCamera(
        70,
        w / h,
        0.001, 100
    );
    camera.position.set(1.5, 0, 2);

    // new OrbitControls(camera, renderer.domElement);

    /* Start custom stuff */
    material = new THREE.ShaderMaterial({
        side: THREE.DoubleSide,
        uniforms: {
            time: { value: 0 },
        },
        vertexShader: vertex,
        fragmentShader: fragment,
    });

    const planeGeometry = new THREE.PlaneBufferGeometry(w, h, 1, 1)
    const plane = new THREE.Mesh(planeGeometry, material);
    scene.add(plane);

    resize();
    window.addEventListener('resize', resize);
}

function animate() {
    time += 0.05;
    material.uniforms.time.value = time;

    requestAnimationFrame(animate);
    render();
}

function render() {
    renderer.render(scene, camera);
}

/*
 * Helper functions and event listeners
 */
function resize() {
    const w = rootContainer.offsetWidth;
    const h = rootContainer.offsetHeight;
    renderer.setSize(w, h);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
}


/*
 * Calls
 */
init();
animate();
