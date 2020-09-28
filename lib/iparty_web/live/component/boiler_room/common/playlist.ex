defmodule IpartyWeb.Live.Component.BoilerRoom.Playlist do
  use IpartyWeb, :live_component
  alias Iparty.Base.YouTube

  # Add video to playlist
  def handle_event("add-to-playlist", %{"value" => video_id}, socket) do
    playitem_uuid = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    video = YouTube.get_vinfo(video_id, :formated)
    playitem = %{info: video, uuid: playitem_uuid}
    playlist = socket.assigns.playlist ++ [playitem]

    {:noreply, assign(socket, :playlist, playlist)}
  end

  # Remove video from playlist
  def handle_event("remove-from-playlist", %{"value" => playitem_uuid} = _data, socket) do
    playlist =
      socket.assigns.playlist
      |> Enum.reject(&(&1.uuid == playitem_uuid))

    {:noreply, assign(socket, :playlist, playlist)}
  end

  # Shufle playlist
  def handle_event("shufle", _, socket) do
    playlist = Enum.shuffle(socket.assigns.playlist)
    {:noreply, assign(socket, :playlist, playlist)}
  end

  # Save playlist to user
  def handle_event("save", _, socket) do
    {:noreply, socket}
  end

  # Playlist repeat
  def handle_event("repeat", _, socket) do
    {:noreply, socket}
  end
end
