defmodule IpartyWeb.Live.View.UserSettings do
  use IpartyWeb, :live_view

  def mount(_attrs, %{"current_user" => user, "google" => google}, socket) do
    socket =
      socket
      |> assign(:current_user, user)
      |> assign(:google, google)

    {:ok, default_assigns(socket)}
  end

  def render(assigns),
    do: Phoenix.View.render(IpartyWeb.User.SettingsView, "settings.html", assigns)

  defp default_assigns(socket) do
    socket
  end
end
