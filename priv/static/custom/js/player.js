let player;
let loop = false;
let time_update_interval = 0;
let volume = 0;

function onYouTubeIframeAPIReady() {
  player = new YT.Player("video_player", {
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
    // videoId: "AjkE4H6Gfpg",
    events: {
      onReady: init,
      onStateChange: onPlayerStateChange,
    },
  });
}

// When video loads init player and player states
function init() {
  console.log("Video ready.");

  update_name();
  initTimerDisplay();
  initProgressBar();
  syncSound(100);
  clearInterval(time_update_interval);

  time_update_interval = setInterval(function () {
    updateTimerDisplay();
    updateProgressBar();
  }, 1000 / 80);
}

// == ProgressBar START ==
function initProgressBar() {
  duration = player.getDuration();
  document.getElementById("progress-bar").max = duration;
  progress = player.getCurrentTime();
  document.getElementById("progress-bar").value = progress;
}

function updateProgressBar() {
  progress = player.getCurrentTime();
  document.getElementById("progress-bar").value = progress;
}

document.getElementById("progress-bar").onmousedown = function () {
  clearInterval(time_update_interval);
};

document.getElementById("progress-bar").onmouseup = function (e) {
  player.seekTo(e.target.value, true);
  initNewPlayStats();
};

function initNewPlayStats() {
  clearInterval(time_update_interval);

  time_update_interval = setInterval(function () {
    updateTimerDisplay();
    updateProgressBar();
  }, 1000 / 80);
}
// == ProgressBar END ==

// -- TimeStamp START --
function initTimerDisplay() {
  updateTimerDisplay();
}
function updateTimerDisplay() {
  document.getElementById("current-time").textContent = formatTime(
    player.getCurrentTime()
  );
  document.getElementById("duration").textContent = formatTime(
    player.getDuration()
  );
}

function formatTime(value) {
  value = Math.round(value);
  var time = Math.floor(value / 60);
  n = value - 60 * time;
  return time + ":" + (n = n < 10 ? "0" + n : n);
}
// -- TimeStamp END --

// Handle iFrame API state change response
function onPlayerStateChange(event) {
  changePlayState(event.data);
}

// On player change state triger needed actions
function changePlayState(state) {
  switch (state) {
    // unstarted
    case -1:
      update_name();
      break;

    // ended
    case 0:
      videoEnded();
      updatePlayIcon("ended");
      break;

    // playing
    case 1:
      update_name();
      initProgressBar();
      initNewPlayStats();
      updatePlayIcon("playing");
      break;

    // paused
    case 2:
      updatePlayIcon("paused");
      break;

    // buffering
    case 3:
      break;

    // video cued
    case 5:
      break;
  }
}

// Play|pause video
document.getElementById("play_button").addEventListener("click", () => {
  // console.log(state)
  state = player.getPlayerState();
  switch (state) {
    case -1:
      player.pauseVideo();
      break;
    case 1:
      player.pauseVideo();
      break;
    default:
      player.playVideo();
  }
});

// Update play|pause icon for state
function updatePlayIcon(state) {
  switch (state) {
    case "playing":
      document.getElementById("play_icon").classList.remove("fa-play");
      document.getElementById("play_icon").classList.add("fa-pause");
      break;
    case "paused":
      document.getElementById("play_icon").classList.remove("fa-pause");
      document.getElementById("play_icon").classList.add("fa-play");
      break;
    case "ended":
      document.getElementById("play_icon").classList.remove("fa-pause");
      document.getElementById("play_icon").classList.add("fa-play");
      break;
  }
}

// Seek back 15s button
document.getElementById("seek_back").addEventListener("click", () => {
  player.seekTo(player.getCurrentTime() - 15, true);
});

// Seek back 15s button
document.getElementById("seek_forw").addEventListener("click", () => {
  player.seekTo(player.getCurrentTime() + 15, true);
});

// Toogle video loop
document.getElementById("loop_video").addEventListener("click", () => {
  loop_btn = document.getElementById("loop_video");

  if (loop == true) {
    replay_icon("replay_off");
    loop = false;
  } else {
    replay_icon("replay_on");
    loop = true;
  }
});

// Update toogle icon for loop state
function replay_icon(state) {
  icon = document.getElementById("loop_video");
  switch (state) {
    case "replay_on":
      icon.classList.toggle("fa-repeat-1");
      break;
    case "replay_off":
      icon.classList.toggle("fa-repeat-1");
      break;
  }
}

// If video has ended play next unless loop is on
function videoEnded() {
  if (loop == true) {
    player.playVideo();
  } else {
    playNextVideo();
  }
}

// Play next video in playlist and sync with server
function playNextVideo() {
  let playItems = getPlaylistItems();
  if (playItems.length > 0) {
    // YoutubePlayer.pushEventTo("");
    let videoId = playItems.items[0].dataset.videoId;
    PlayVideoId(videoId);
  }
}

// Get all playitem of playlist
function getPlaylistItems() {
  let items = document.getElementsByClassName("playitem");
  let result = {
    items: items,
    length: items.length,
  };
  return result;
}

// When volume slider changes ajust sound
document.getElementById("volume-bar").oninput = function () {
  syncSound(this.value);
};

// Toogle mute|unmute
document.getElementById("mute_btn").addEventListener("click", () => {
  if (player.isMuted() == true) {
    player.unMute();
    sound_icon("unmuted");
  } else {
    volume = player.getVolume();
    player.mute();
    sound_icon("muted");
  }
});

// Update sound icon for mute state
function sound_icon(state) {
  icon = document.getElementById("mute_btn");
  switch (state) {
    case "unmuted":
      icon.classList.toggle("fa-volume-mute");
      icon.classList.toggle("has-text-danger");
      syncSound(volume);
      break;
    case "muted":
      icon.classList.toggle("fa-volume-mute");
      icon.classList.toggle("has-text-danger");
      syncSound(0);
      break;
  }
}

// Set tound to input value
function syncSound(value) {
  document.getElementById("volume-bar").value = value;
  player.setVolume(value);
}

// Toogle settings window
document.getElementById("settings_icon").addEventListener("click", () => {
  document.getElementById("settings_options").classList.toggle("hidden");
  document.getElementById("settings_options").classList.toggle("flex");
});

// Update video name
function update_name() {
  document.getElementById(
    "player_awning"
  ).dataset.content = player.getVideoData().title;
}

// Play video
function PlayVideoId(videoId) {
  player.loadVideoById(videoId, 0, "low");
  // Add video to play history
  // popOnHistory(videoId)

  // Get related videos
  fetchRelated(videoId);
}

// Play video from second
function PlayVideoIdTimestamp(videoId, id) {
  let timestamp = document.getElementById(id).value;
  player.loadVideoById(videoId, timestamp, "medium");
}

function popOnHistory(videoId) {
  YoutubePlayer.pushEventTo("#play-history", "plh-add", { videoId });
}

function fetchRelated(videoId) {
  YoutubePlayer.pushEventTo("#related-videos", "relate", { videoId });
}
