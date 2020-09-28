defmodule IpartyWeb.Live.Component.BoilerRoom.Comon.UsersOnline do
  use IpartyWeb, :live_view
  alias Iparty.BoilerRoomPresence, as: Presence

  def mount(_assigns, %{"room" => room} = _session, socket) do
    if connected?(socket) do
      topic = "boiler-room:#{room.slug}"
      # Subscribe to the topic
      IpartyWeb.Endpoint.subscribe(topic)
      # Notify other users
      Presence.track(self(), topic, socket.id, %{})
      # Init value
      users_online = Presence.list(topic) |> map_size

      socket =
        socket
        |> assign(:users_online, users_online)
        |> assign(:room, room)

      {:ok, socket}
    else
      socket =
        socket
        |> assign(:users_online, 1)
        |> assign(:room, room)

      {:ok, socket}
    end
  end

  def render(assigns) do
    ~L"""
      <h2 class="flex justify-center items-center text-gray-900 dark:text-sage-500" id="room-online-users">
        <i class="fad fa-eye"></i> <%= @users_online %>
      </h2>
    """
  end

  def handle_event("refresh-state", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    room = socket.assigns.room
    topic = "boiler-room:#{room.slug}"
    %{"online-users-component" => %{metas: list}} = Presence.list(topic)
    {:noreply, assign(socket, :users_online, length(list))}
  end

  # This part is the key here you recieve msg from
  # server and dispatch it to users inside a room
  def handle_info({:update_player, player}, socket),
    do: {:noreply, push_event(socket, "update-player", player)}
end
