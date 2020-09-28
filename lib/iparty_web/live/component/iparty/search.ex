defmodule IpartyWeb.Live.Component.Iparty.Search do
  use IpartyWeb, :live_component
  alias Iparty.Base.{YouTube, Expired}

  # Video search with Google access token
  def handle_event("search", %{"search_form" => %{"query" => query}}, socket) do
    token = socket.assigns.google

    {:ok, token} = Expired.google(token)
    handle_seach(socket, query, token)
  end

  # Search suggestion
  def handle_event("suggest", %{"value" => input}, socket) do
    handle_suggest(socket, input)
  end

  defp handle_suggest(socket, ""), do: {:noreply, socket}

  defp handle_suggest(socket, query) do
    [search, result] = query |> YouTube.suggest()

    socket =
      socket
      |> assign(:suggestions, result)
      |> assign(:search, search)

    {:noreply, socket}
  end

  defp handle_seach(socket, _, nil) do
    socket =
      socket
      |> assign(:connected, false)
      |> assign(:search_results, [])

    {:noreply, socket}
  end

  defp handle_seach(socket, query, token) do
    response = YouTube.search(query, token.access_token)

    socket =
      socket
      |> assign(:connected, true)
      |> assign(:search_results, response["items"])
      |> assign(:google, token)

    {:noreply, socket}
  end
end
