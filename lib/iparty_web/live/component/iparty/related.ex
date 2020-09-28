defmodule IpartyWeb.Live.Component.Iparty.Related do
  use IpartyWeb, :live_component
  alias Iparty.Base.YouTube

  def handle_event("relate", %{"videoId" => _}, %{assigns: %{google: nil}} = socket) do
    {:noreply, socket}
  end

  def handle_event(
        "relate",
        %{"videoId" => videoId},
        %{assigns: %{google: %{access_token: token}}} = socket
      ) do
    related = videoId |> YouTube.related(token) |> parse()

    {:noreply, assign(socket, related: related)}
  end

  defp parse(%{"items" => items} = _data) when is_list(items) do
    items
    |> Enum.map(fn item ->
      %RelatedItem{
        id: item["id"]["videoId"],
        title: item["snippet"]["title"],
        channel: item["snippet"]["channelTitle"],
        description: item["snippet"]["description"],
        thumbnails: %{
          med: item["snippet"]["thumbnails"]["medium"]["url"],
          high: item["snippet"]["thumbnails"]["high"]["url"]
        }
      }
    end)
  end
end
