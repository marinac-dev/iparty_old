defmodule IpartyWeb.Live.Component.Common.Orientation do
  use IpartyWeb, :live_component

  def handle_event("screen-orientation", orientation, socket),
    do: {:noreply, assign(socket, :orientation, orientation)}
end
