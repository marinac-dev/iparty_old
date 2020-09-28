defmodule IpartyWeb.Live.View.Iparty do
  use IpartyWeb, :live_view

  def mount(_attrs, %{"current_user" => user, "google" => google}, socket) do
    socket =
      socket
      |> assign(:current_user, user)
      |> assign(:google, google)
      |> assign(:true_google, google)

    {:ok, default_assigns(socket)}
  end

  def render(assigns) do
    ~L"""
      <div class="flex flex-col justify-start items-center mx-4 my-2 rounded py-4">
        <!-- Check if orientation is landscape on mobile devices -->
        <%= live_component @socket, IpartyWeb.Live.Component.Common.Orientation, id: :orientation, orientation: @orientation %>
        <!-- Player | Search -->
        <div class="flex flex-col lg:flex-row bg-gray-300 dark:bg-erie-black-800 rounded-md p-2 w-full justify-center items-center">
          <!-- Recommend & History | Player -->
          <div class="flex flex-col lg:flex-row justify-center items-center w-full lg:w-2/3">
            <!-- Recommend & History | -->
            <div class="flex flex-row w-full rounded bg-gray-200 dark:bg-erie-black-600 lg:w-1/3 mb-2 lg:mb-0">
              <%= live_component @socket, IpartyWeb.Live.Component.Iparty.RelatedAndHistory, Map.merge(assigns, %{id: :recommended}) %>
            </div>
            <!-- YT player -->
            <%= live_component @socket, IpartyWeb.Live.Component.Iparty.Player %>
          </div>
          <!-- Search videos -->
          <%= live_component @socket, IpartyWeb.Live.Component.Iparty.Search, Map.merge(assigns, %{id: :search}) %>
        </div>
        <!-- Playlist -->
        <%= live_component @socket, IpartyWeb.Live.Component.Iparty.Playlist, Map.merge(assigns, %{id: :playlist}) %>
      </div>
    """
  end

  defp default_assigns(socket) do
    socket
    # Screen orientation UX
    |> assign(:orientation, nil)
    # Related videos
    |> assign(:related, [])
    # Player history
    |> assign(:history, [])
    # Search input field value
    |> assign(:search, "")
    # Google Account
    |> assign(:connected, true)
    # Search suggestions
    |> assign(:suggestions, [])
    # Search results
    |> assign(:search_results, [])
    # TODO: List import | DEFAULT: Init empty playlist
    |> assign(:playlist, %PlayList{})
  end
end
