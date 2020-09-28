defmodule IpartyWeb.Live.Component.BoilerRoom.Search do
  use IpartyWeb, :live_component

  alias Iparty.Base.{YouTube, Google}

  # Video search with Google access token
  def handle_event("search", %{"search_form" => %{"query" => query}}, socket) do
    token = socket.assigns.google

    {:ok, token} = expired(token)
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
      |> assign(:search_suggestions, result)
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

  defp expired(nil) do
    user = Iparty.Repo.get_by!(Iparty.Accounts.User, email: "iparty.rs@gmail.com")
    token = Iparty.Accounts.get_google_o_auth(user.id, :user)

    case token do
      nil ->
        {:ok, nil}

      token ->
        expired(token)
    end
  end

  defp expired(%{expire_at: expire} = token) do
    now = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_naive()

    if expire > now do
      {:ok, token}
    else
      Google.refresh_token(token)
    end
  end
end
