defmodule IpartyWeb.Live.Component.BoilerRoom.Owner.Player do
  use IpartyWeb, :live_component

  defstruct state: nil, time: 0, volume: 0, song_id: ""

  def handle_event("update-state", params, socket) do
    if connected?(socket) do
      %{"command" => command, "value" => value, "metas" => metadata} = params
      time = DateTime.utc_now() |> DateTime.to_unix()
      diff = time - metadata["timestamp"]
      metadata = Map.merge(metadata, %{serverstamp: time, diff: diff})
      room = socket.assigns.room
      topic = "boiler-room:#{room.slug}"
      msg = {:update_player, %{command: command, state: value, metadata: metadata}}
      Phoenix.PubSub.broadcast(Iparty.PubSub, topic, msg)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
