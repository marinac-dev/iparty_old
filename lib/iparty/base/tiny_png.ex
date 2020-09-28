defmodule Iparty.Base.TinyPng do
  @api_url "https://api.tinify.com/shrink"
  # 6 api keys = 3000 images
  @api_keys ~w(hG6KQXv4lmhsg435tgRqLqlb6WhPZvbq 5hVRlXCq3Dp3hBx2r6Q9dB9ct29pmBXx Bj6j2Nqnkz3mQQ1H8MlgFlV98nzpxrJt 2vjPf9ZP5lW28NrXQBQ0k0ZVvsHbDp9w FDgfHXYrpYCN7Hl1wKTYTxFwW96jy6kT m5VbJ8L1c2NNdMMRrQx1JVVJMfm34rz1)

  def compress(data, :binary),
    do: process(data)

  def compress(data, :url) do
    {:ok, body} = Poison.encode(%{source: %{url: data}})
    process(body)
  end

  defp process(body) do
    api_key = Enum.random(@api_keys)
    auth = Base.encode64("api:#{api_key}")

    headers = [
      {"Content-Type", "application/json; charset=utf-8"},
      {"Authorization", "Basic " <> auth}
    ]

    {:ok, %{body: resp}} = HTTPoison.post(@api_url, body, headers)
    Jason.decode!(resp)
  end
end
