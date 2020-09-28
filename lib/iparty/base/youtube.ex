defmodule Iparty.Base.YouTube do
  # iparty.rs@gmail.com API Key

  # Api urls
  @info_url "https://www.googleapis.com/youtube/v3/videos"
  @search_url "https://www.googleapis.com/youtube/v3/search"
  @suggest_url "http://suggestqueries.google.com/complete/search"
  # Args
  @extra "&type=video&videoDimension=2d&videoEmbeddable=true&safeSearch=none&maxResults=25"
  @snippet "?part=snippet"
  @snippet_contentDetails "?part=snippet,contentDetails"

  # Search video with USER ACCESS TOKEN
  def search(query, token) do
    uri_query = URI.encode(query)
    %{body: response} = call_search_api(uri_query, token)
    response |> Jason.decode!()
  end

  # Get related videos to video id
  def related(video_id, token) do
    params = "?part=snippet&relatedToVideoId=#{video_id}#{@extra}&access_token=#{token}"
    {:ok, %{body: response}} = HTTPoison.get(@search_url <> params <> @extra)
    response |> Jason.decode!()
  end

  # User search suggestion
  def suggest(query) do
    uri_query = URI.encode(query)
    params = "?client=firefox&ds=yt&q="
    %{body: response} = HTTPoison.get!(@suggest_url <> params <> uri_query)

    response |> Jason.decode() |> handle_suggest()
  end

  defp handle_suggest({:ok, [search_query, result | _]}), do: [search_query, result]
  defp handle_suggest({:error, _}), do: ["", []]

  # Get video information
  def get_vinfo(nil, _), do: nil
  def get_vinfo(_, nil), do: nil
  def get_vinfo(nil, nil), do: nil

  def get_vinfo(video_id, access_token) do
    params = "#{@snippet_contentDetails}&id=#{video_id}&access_token=#{access_token}"
    HTTPoison.get(@info_url <> params) |> parse_vinfo()
  end

  defp parse_vinfo({:ok, %{body: response}}) do
    response
    |> Jason.decode()
    |> parse_response()
  end

  defp parse_vinfo({:error, _}), do: nil

  defp parse_response({:ok, %{"items" => [video]}}) do
    id = video["id"]
    title = video["snippet"]["title"]
    thumb = video["snippet"]["thumbnails"]
    descr = video["snippet"]["description"]
    v_len = video["contentDetails"]["duration"]
    duration = get_from_iso8601_duration(v_len, :seconds)
    med = thumb["medium"]
    high = thumb["high"]

    %PlayItem{
      description: descr,
      duration: duration,
      thumbnails: %{med: med, high: high},
      title: title,
      id: id
    }
  end

  defp parse_response({:error, _}), do: nil

  # Helpers and private fn-s

  defp call_search_api(q, t),
    do: HTTPoison.get!("#{@search_url}#{@snippet}#{@extra}&q=#{q}&access_token=#{t}")

  defp get_from_iso8601_duration(time, :seconds) do
    {:ok, duration} = Timex.Parse.Duration.Parser.parse(time)
    Timex.Duration.to_seconds(duration)
  end

  defp get_from_iso8601_duration(time, :clock) do
    {:ok, duration} = Timex.Parse.Duration.Parser.parse(time)
    Timex.Duration.to_clock(duration)
  end
end
