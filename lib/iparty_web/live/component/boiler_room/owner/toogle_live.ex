defmodule IpartyWeb.Live.Component.BoilerRoom.Owner.ToogleLive do
  use IpartyWeb, :live_component

  alias Iparty.{Accounts}

  def handle_event("live-toogle", _params, socket) do
    room = socket.assigns.room
    online = !room.online
    {:ok, room} = Accounts.update_boiler_room(room, %{online: online})
    {:noreply, assign(socket, :room, room)}
  end
end
