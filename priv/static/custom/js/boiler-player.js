let player;
let loop = false;
let time_update_interval = 0;

function onYouTubeIframeAPIReady() {
  player = new YT.Player("yt-player", {
    max_height: "390",
    width: "640",
    playerVars: {
      fs: 0,
      rel: 0,
      controls: 0,
      disablekb: 1,
      enablejsapi: 1,
      playsinline: 1,
      modestbranding: 1,
      cc_load_policy: 0,
      origin: window.location.hostname,
    },
    videoId: "ele2DMU49Jk",
    events: {
      onReady: init,
      onStateChange: onPlayerStateChange,
    },
  });
}

// When video loads init player
function init() {
  console.log("Video ready.");
  // player.playVideo();

  // update_name();
  // initTimerDisplay();
  // syncSound(100);
  initProgressBar();
  clearInterval(time_update_interval);

  time_update_interval = setInterval(function () {
    // updateTimerDisplay();
    updateProgressBar();
  }, 1000 / 80);
}

// Handle iFrame API state change response
// START
function onPlayerStateChange(event) {
  console.log("State change:" + event.data);
  // changePlayState(event.data);
}

// == ProgressBar START ==
function initProgressBar() {
  let duration = player.getDuration();
  document.querySelector("#br-seeker").max = duration;
  let progress = player.getCurrentTime();
  document.querySelector("#br-seeker").value = progress;
}

function updateProgressBar() {
  let progress = player.getCurrentTime();
  document.querySelector("#br-seeker").value = progress;
}

function initNewPlayStats() {
  clearInterval(time_update_interval);

  time_update_interval = setInterval(function () {
    // updateTimerDisplay();
    updateProgressBar();
  }, 1000 / 80);
}
// == ProgressBar END ==
