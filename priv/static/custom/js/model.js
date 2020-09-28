import * as THREE from "https://min.gitcdn.link/repo/mrdoob/three.js/dev/build/three.module.js";
import { GLTFLoader } from "https://min.gitcdn.link/repo/mrdoob/three.js/dev/examples/jsm/loaders/GLTFLoader.js";
import { WEBGL } from "https://min.gitcdn.link/repo/mrdoob/three.js/dev/examples/jsm/WebGL.js";
import { AnaglyphEffect } from "https://min.gitcdn.link/repo/mrdoob/three.js/dev/examples/jsm/effects/AnaglyphEffect.js";

let renderer, scene, camera, effect, container, width, height;
let loader, logo, pointLightLeft, pointLightRight;
let mouseX = 0,
  mouseY = 0;

function init() {
  container = document.querySelector("#logo");
  width = container.clientWidth;
  height = container.clientHeight;

  // Scene
  scene = new THREE.Scene();

  const fov = 45;
  const aspect = width / height;
  const near = 0.1;
  const far = 650;

  // Camera setup
  camera = new THREE.PerspectiveCamera(fov, aspect, near, far);
  camera.position.set(-0.65, 0, 6);

  const ambient = new THREE.AmbientLight("white", 10);
  scene.add(ambient);

  // Renderer
  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(window.devicePixelRatio);

  container.appendChild(renderer.domElement);

  // Load modal
  loader = new GLTFLoader();

  loader.load("/models/iparty2.glb",
    function (gltf) {
      scene.add(gltf.scene);
      logo = gltf.scene;
      logo.rotation.y -= 0.85;
      logo.position.y -= 0.65;
      logo.position.x -= 1;
      logo.scale.set(0.7, 0.7, 0.7);

      animate();
    },
    undefined,
    function (error) {
      console.error(error);
    }
  );

  // Grid
  let grid_bot = new THREE.GridHelper(2000, 100, "#c825e8", "#c825e8");
  let grid_top = new THREE.GridHelper(2000, 100, "#c825e8", "#c825e8");
  grid_bot.position.y = -75;
  grid_top.position.y = +75;
  scene.add(grid_bot);
  scene.add(grid_top);

  // Point light
  // left
  pointLightLeft = new THREE.PointLight("#fc00ff", 1);
  pointLightLeft.position.x = -7;
  pointLightLeft.position.z = 10;

  // right
  pointLightRight = new THREE.PointLight("#00dbde", 1);
  pointLightRight.position.x = 7;
  pointLightRight.position.z = 10;

  scene.add(pointLightLeft);
  scene.add(pointLightRight);

  // Effect
  effect = new AnaglyphEffect(renderer);
  effect.setSize(width, height);
}

if (WEBGL.isWebGLAvailable()) {
  init();
  animate();
} else {
  var warning = WEBGL.getWebGLErrorMessage();
  document.getElementById("container").appendChild(warning);
}

function animate() {
  requestAnimationFrame(animate);

  render();
}

function render() {
  camera.position.x += (mouseX - camera.position.x) * 0.0015;
  camera.position.y += (-mouseY - camera.position.y) * 0.0015;

  camera.lookAt(scene.position);

  if (effect) {
    effect.render(scene, camera);
  } else {
    renderer.render(scene, camera);
  }
}

window.addEventListener("resize", () => {
  width = window.innerWidth;
  height = window.innerHeight;

  camera.aspect = width / height;
  camera.updateProjectionMatrix();

  if (effect) {
    effect.setSize(width, height);
  } else {
    renderer.setSize(width, height);
  }
});

window.addEventListener("mousemove", () => {
  mouseX = (event.clientX - window.innerWidth / 2) / 100;
  mouseY = (event.clientY - window.innerHeight / 2) / 100;
});
