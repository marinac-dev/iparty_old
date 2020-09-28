defmodule IpartyWeb.Live.View.AllRooms do
  use IpartyWeb, :live_view

  alias Iparty.{Base.Pagination, Accounts, Accounts.BoilerRoom}

  def mount(_assigns, session, socket),
    do: {:ok, default_assigns(socket, session)}

  defp default_assigns(socket, session) do
    pagination = Pagination.generate(BoilerRoom, :online_rooms)

    socket
    |> assign(:suggestions, [])
    |> assign(:pagination, pagination)
    |> assign(:rooms, pagination.items)
    |> assign(:current_user, session["user"])
  end

  def handle_event("suggest", %{"search_form" => %{"search_input" => value}}, socket),
    do: {:noreply, assign(socket, :suggestions, Accounts.suggest_boiler_room(value))}

  def handle_event("search", %{"search_form" => %{"search_input" => query}}, socket),
    do: {:noreply, assign(socket, :rooms, Accounts.search_boiler_room(query, :online))}
end
