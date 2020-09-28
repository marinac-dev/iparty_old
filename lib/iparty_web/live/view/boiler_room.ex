defmodule IpartyWeb.Live.View.BoilerRoom do
  use IpartyWeb, :live_view

  def render(assigns) do
    ~L"""
    <div class="flex flex-col items-start justify-center lg:justify-start mx-4 my-3 ">
      <%= if @owner do %>
        <p class="w-full bg-gray-900 text-teal-300 px-2 py-4 mb-3 rounded-lg shadow text-center">
          You are the owner! 😎
        </p>
      <% end %>
      <!-- Check if orientation is landscape on mobile devices -->
      <%= live_component @socket, IpartyWeb.Live.Component.Common.Orientation, id: :orientation, orientation: @orientation %>

      <%= if @owner do %>
        <!-- Owner -->
        <%= live_component @socket, IpartyWeb.Live.Component.BoilerRoom.Owner.Main, Map.merge(assigns,  %{id: "owner-main"}) %>
      <% else %>
        <!-- Visitor -->
        <%= live_component @socket, IpartyWeb.Live.Component.BoilerRoom.Visitor.Main, Map.merge(assigns,  %{id: "visitor-main"}) %>
      <% end %>
    </div>
    """
  end

  def mount(_assigns, session, socket),
    do: {:ok, default_assigns(socket, session)}

  defp default_assigns(socket, %{"user" => user, "room" => room, "google" => google} = _session) do
    owner = is_owner?(room, user)

    socket
    # Player thing
    |> assign(:google, google)
    |> assign(:orientation, nil)
    # Boiler room things
    |> assign(:room, room)
    |> assign(:user, user)
    |> assign(:owner, owner)
    # Search bar things
    |> assign(:search, "")
    |> assign(:search_suggestions, [])
    |> assign(:connected, true)
    |> assign(:search_results, [])
    # Playlist things
    |> assign(:playlist, [])
    |> assign(:suggestions, [])
  end

  defp is_owner?(_room, nil), do: false
  defp is_owner?(room, user), do: room.user_id == user.id
end
