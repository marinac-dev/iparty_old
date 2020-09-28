defmodule IpartyWeb.Live.Component.Tags do
  use IpartyWeb, :live_component

  def handle_event("boiler-room-tags", %{"value" => value}, socket) do
    tags =
      value
      |> String.split(",")
      |> Enum.reject(&(&1 == " "))
      |> Enum.reject(&(&1 == ""))

    {:noreply, assign(socket, tags: tags)}
  end
end
