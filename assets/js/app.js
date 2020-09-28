// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// 3D landing with Three JS
import * as THREE from "three/src/Three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader";
import { WEBGL } from "three/examples/jsm/WebGL";
import { AnaglyphEffect } from "three/examples/jsm/effects/AnaglyphEffect";

// webpack automatically bundles all modules in your entry points. Those entry points can be configured in "webpack.config.js".
// Import deps with the dep name or local files with a relative path, for example:
//     import {Socket} from "phoenix"
//     import socket from "./socket"

import "alpinejs";
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import {
  IcosahedronBufferGeometry,
  TorusBufferGeometry,
} from "three/src/Three";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// Hooks
let Hooks = {};

// ~~ Youtube player START ~~
// Mount player
Hooks.YoutubePlayer = {
  mounted() {
    window.YoutubePlayer = this;
    mountPlayer();
  },
};

// Search suggest
Hooks.SearchSuggest = {
  mounted() {
    let input = document.querySelector("#search-input");
    input.addEventListener("input", (event) => {
      let value = event.target.value;
      this.pushEventTo("#search-form", "suggest", { value });
    });
  },
};
// ~~ Youtube player END ~~

// ~~ Boiler room player START ~~
Hooks.BoilerRoom = {
  mounted() {
    mountPlayer();
    this.handleEvent("update-song", ({ videoId, startTime }) =>
      player.loadVideoById(videoId, startTime, "low")
    );
  },
};

// ~~ Player part ~~
// Mount player
Hooks.BoilerPlayer = {
  mounted() {
    let tag = document.createElement("script");
    let tag2 = document.createElement("script");
    let firstScriptTag = document.getElementsByTagName("script")[0];

    tag.src = "https://www.youtube.com/iframe_api";
    tag2.src = "/custom/js/boiler-player.js";
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    firstScriptTag.parentNode.insertBefore(tag2, firstScriptTag);
  },
};

Hooks.BoilerPlayerVisitor = {
  mounted() {
    // Expose request
    let Local_Player = this;
    window.sendEventTo = function (target_id, event_name, params) {
      Local_Player.pushEventTo(target_id, event_name, params);
    };

    // Init player
    init_player();

    // Request state update
    requestStateUpdate();

    // Handle update state
    this.handleEvent("update-player", (data) => {
      handle_data(data);
    });
  },
};

function requestStateUpdate() {
  sendEventTo("#room-online-users", "refresh-state", "");
}

function init_player() {
  let tag = document.createElement("script");
  let tag2 = document.createElement("script");
  let firstScriptTag = document.getElementsByTagName("script")[0];

  tag.src = "https://www.youtube.com/iframe_api";
  tag2.src = "/custom/js/boiler-player-visitor.js";
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  firstScriptTag.parentNode.insertBefore(tag2, firstScriptTag);
}

function handle_data(data) {
  console.log("State: " + data.state);
  switch (data.state) {
    // Unstarted
    case -1:
      player.playVideo();
      break;

    // Ended
    case 0:
      break;

    // Playing
    case 1:
      player.pauseVideo();
      break;

    // Paused
    case 2:
      player.playVideo();
      break;

    // Buffering
    case 3:
      break;

    // Video cued
    case 5:
      break;

    default:
      return null;
  }
}

// Player settings debounce
Hooks.BoilerPlayerSettings = {
  mounted() {
    const seeker = document.querySelector("#br-seeker");
    const volume = document.querySelector("#br-volume");
    // Player buttons
    const stop = document.querySelector("#br-stop");
    const play = document.querySelector("#br-play");
    const next = document.querySelector("#br-next");
    const prev = document.querySelector("#br-prev");

    // Broadcast play or pause the video
    play.addEventListener("click", (event) => {
      let value = player.getPlayerState();
      let timestamp = Date.now().toString().slice(0, -3);
      player.playVideo();

      player.playVideo();
      this.pushEventTo("#room-player", "update-state", {
        command: "play-pause",
        value: value,
        metas: { timestamp: parseInt(timestamp) },
      });
    });

    // Broadcast stop
    stop.addEventListener("click", (event) => {
      let value = player.getPlayerState();
      let timestamp = Date.now().toString().slice(0, -3);
      this.pushEventTo("#room-player", "update-state", {
        command: "stop",
        value: value,
        metas: { timestamp: parseInt(timestamp) },
      });
    });

    // Broadcast next
    next.addEventListener("click", (event) => {
      let value = player.getPlayerState();
      let timestamp = Date.now().toString().slice(0, -3);

      player.playVideo();
      this.pushEventTo("#room-player", "update-state", {
        command: "next",
        value: value,
        metas: { timestamp: parseInt(timestamp) },
      });
    });

    // Broadcast prev
    prev.addEventListener("click", (event) => {
      let value = player.getPlayerState();
      let timestamp = Date.now().toString().slice(0, -3);

      player.playVideo();
      this.pushEventTo("#room-player", "update-state", {
        command: "prev",
        value: value,
        metas: { timestamp: parseInt(timestamp) },
      });
    });

    // Broadcast seeker
    seeker.addEventListener("input", (event) => {
      let value = player.getPlayerState();
      let timestamp = Date.now().toString().slice(0, -3);
      this.pushEventTo("#room-player", "update-state", {
        command: "seeker",
        value: value,
        metas: { timestamp: parseInt(timestamp) },
      });
    });

    seeker.onmousedown = function () {
      clearInterval(time_update_interval);
    };

    seeker.onmouseup = function (e) {
      player.seekTo(e.target.value, true);
      initNewPlayStats();
    };
  },
};

Hooks.SearchSuggestBoilerRoom = {
  mounted() {
    let input = document.querySelector("#search-input");
    input.addEventListener("input", (event) => {
      let value = event.target.value;
      this.pushEventTo("#boiler-search-form", "suggest", { value });
    });
  },
};
// ~~ Boiler room player END ~~

// Create boiler room
Hooks.BoilerRoomTag = {
  mounted() {
    let input = document.querySelector("#tag-input");
    input.addEventListener("input", (event) => {
      let value = event.target.value;
      this.pushEventTo("#tags", "boiler-room-tags", { value });
    });
  },
};

// Phone screen orientation
Hooks.ScreenOrientation = {
  mounted() {
    this.pushEventTo(
      "#orientation",
      "screen-orientation",
      getOrientation(window.orientation)
    );

    window.addEventListener("orientationchange", () => {
      this.pushEventTo(
        "#orientation",
        "screen-orientation",
        getOrientation(window.orientation)
      );
    });
  },
};

function getOrientation(degree) {
  switch (degree) {
    case -90:
    case 90:
      return "landscape";

    default:
      return "portrait";
  }
}

// Landing page
Hooks.IndexPage = {
  mounted() {
    // Landing page | Default 2D
    if (!localStorage.getItem("landing-3d")) {
      localStorage.setItem("landing-3d", "false");
    }
    // Retrieve localStorage value for landing
    const ls = localStorage.getItem("landing-3d");
    // Auto check checkbox
    document.querySelector("#toogle-3d").checked = ls == "true" ? true : false;
    // Update landing if needed | dumb solution fix this >:/
    if (ls == "true") {
      setTimeout(() => {
        this.pushEvent("change-landing", { value: true });
      }, 1500);
    }
    // Add event listener for toogle
    document.querySelector("#toogle-3d").addEventListener("change", (event) => {
      let op = ls == "true" ? "false" : "true";
      localStorage.setItem("landing-3d", op);
      let check = document.querySelector("#toogle-3d").checked;
      this.pushEvent("change-landing", { value: check });
    });
  },
};

// LAST HOOK
Hooks.Landing3D = {
  mounted() {
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

      loader.load(
        "/models/iparty2.glb",
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
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Helper fn-s
function mountPlayer() {
  let tag = document.createElement("script");
  let tag2 = document.createElement("script");
  let firstScriptTag = document.getElementsByTagName("script")[0];

  tag.src = "https://www.youtube.com/iframe_api";
  tag2.src = "/custom/js/player.js";
  firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  firstScriptTag.parentNode.insertBefore(tag2, firstScriptTag);
}

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket;

// Burger menu
const burger = document.querySelector("#burger-menu");
const navbar = document.querySelector("#navbar-menu");

burger.addEventListener("click", () => {
  navbar.classList.toggle("hidden");
});
