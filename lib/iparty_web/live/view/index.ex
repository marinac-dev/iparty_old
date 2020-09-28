defmodule IpartyWeb.Live.View.Index do
  use IpartyWeb, :live_view

  def mount(_attrs, _session, socket),
    do: {:ok, assign(socket, :landing, "2d")}

  def render(assigns),
    do: Phoenix.View.render(IpartyWeb.PageView, "index-live.html", assigns)

  def handle_event("change-landing", %{"value" => true}, socket),
    do: {:noreply, assign(socket, landing: "3d")}

  def handle_event("change-landing", %{"value" => false}, socket),
    do: {:noreply, assign(socket, landing: "2d")}

  # def handle_event(_, _, socket), do: {:noreply, socket}
end
