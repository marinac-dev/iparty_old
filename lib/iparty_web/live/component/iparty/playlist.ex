defmodule IpartyWeb.Live.Component.Iparty.Playlist do
  use IpartyWeb, :live_component

  require Logger
  alias Iparty.Base.{YouTube, Expired}

  # Add video to playlist
  def handle_event("pl-add", %{"value" => video_id}, %{assigns: %{google: google}} = socket) do
    {:ok, token} = Expired.google(google)
    handle_video(socket, YouTube.get_vinfo(video_id, token.access_token))
  end

  # Remove video from playlist
  def handle_event("pl-remove", %{"value" => uuid}, %{assigns: %{playlist: playlist}} = socket) do
    item = PlayList.get_item(playlist, uuid)
    playlist |> PlayList.remove(item) |> handle_remove(socket)
  end

  # Shufle playlist
  def handle_event("shufle", _, socket) do
    {:ok, playlist} = PlayList.shuffle(socket.assigns.playlist)
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

  defp handle_video(socket, nil), do: {:noreply, socket}

  defp handle_video(%{assigns: %{playlist: playlist}} = socket, %PlayItem{} = video) do
    video = %{video | uuid: gen_uuid()}
    playlist |> PlayList.add(video) |> handle_add(socket)
  end

  defp handle_add({:ok, p_list}, socket),
    do: {:noreply, assign(socket, :playlist, p_list)}

  defp handle_add({:error, [msg, _]}, socket) do
    Logger.warn(msg)
    {:noreply, put_flash(socket, :info, msg)}
  end

  defp handle_remove({:ok, p_list}, socket),
    do: {:noreply, assign(socket, :playlist, p_list)}

  defp handle_remove({:error, [msg, _p_list]}, socket) do
    Logger.info(msg)
    {:noreply, socket}
  end

  defp gen_uuid(),
    do: :crypto.strong_rand_bytes(12) |> Base.url_encode64(padding: false)
end
