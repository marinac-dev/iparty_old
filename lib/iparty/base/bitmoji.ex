defmodule Iparty.Base.Bitmoji do
  defstruct gender: nil, params: %{unisex: nil, gender: nil}
  alias(__MODULE__, as: Bitmoji)

  # Base bitmoji url
  @url "https://preview.bitmoji.com/avatar-builder-v3/preview/"
  @unisex ~w(brow cheek_details ear eye eyelash eye_details face_lines glasses hair hat jaw mouth nose blush_tone brow_tone eyeshadow_tone hair_tone hair_treatment_tone lipstick_tone pupil_tone skin_tone body face_proportion eye_spacing eye_size)
  @male ~w(beard beard_tone)
  @female ~w(breast)

  # Generate random Bitmoji only url
  def create(:random, :url), do: randomize(:url)
  # Generate random bitmoji in binary format
  def create(:random, :binary), do: randomize(:binary)
  # Generate random bitmoji and save to file
  def create(:random, :file), do: randomize(:binary) |> save()
  # Generate random bitmoji in base64 format
  def create(:random, :base64), do: randomize(:binary) |> Base.encode64(padding: false)

  # Generate customizable bitmoji as url
  def create(%Bitmoji{} = config, :url), do: bitmoji(config, :config)
  # Generate customizable bitmoji in binary format
  def create(%Bitmoji{} = config, :binary), do: bitmoji(config, :config) |> HTTPoison.get!()
  # Generate customizable bitmoji in base64 format
  def create(%Bitmoji{} = config, :base64),
    do: bitmoji(config, :config) |> Base.encode64(padding: false)

  def get_categories(:male), do: @male ++ @unisex
  def get_categories(:female), do: @female ++ @unisex

  # PRIVATE FNS
  # Returns bitmoji url
  defp randomize(:url) do
    {genre, gender_int} = random_gender()
    params = {genre, gender_int}
    generate(params, :url)
  end

  # Returns bitmoji binary
  defp randomize(:binary) do
    {genre, gender_int} = random_gender()
    params = {genre, gender_int}
    generate(params, :data)
  end

  # Random bitmoji url
  defp generate(params, :url) when is_tuple(params), do: bitmoji(params, :random)

  # Binary data from random bitmoji url
  defp generate(params, :data) when is_tuple(params) do
    url = bitmoji(params, :random)
    %{body: resp} = HTTPoison.get!(url)
    resp
  end

  # Generates random bitmoji url
  defp bitmoji({genre, gender_int}, :random) do
    params = random_params(genre)
    build_url(params, gender_int)
  end

  # Generate bitmoji from config
  defp bitmoji(config, :config) do
    # Get genre
    {genre, gender_int} = gender(config.gender)
    params = random_params(genre)
    build_url(params, gender_int)
  end

  defp random_gender, do: Enum.random(1..2) |> random_gender()
  defp random_gender(1), do: {"male", 1}
  defp random_gender(2), do: {"female", 2}

  defp gender("male"), do: {"male", 1}
  defp gender("female"), do: {"female", 2}

  # Build url from params
  defp build_url(params, gender_int) do
    url = Enum.map(params, fn [n, %{"value" => v}] -> "#{n}=#{v}" end) |> Enum.join("&")
    @url <> "head?scale=1&rotation=0&style=5&gender=#{gender_int}&" <> url
  end

  # Generate random params from genre
  defp random_params(genre) do
    # Load bitmoji assets
    assets = json()

    assets[genre]["categories"]
    |> Enum.map(fn cat ->
      value = Enum.random(cat["options"])
      [cat["key"], value]
    end)
  end

  # Read assets.json file with for Bitmoji creation
  def json(), do: file_read("assets.json") |> Jason.decode!()
  defp file_read(name), do: File.read!("#{file()}/#{name}")
  defp file(), do: "#{:code.priv_dir(:iparty)}/static/json/"

  # Save bitmoji to file
  def save(data) when is_binary(data) do
    name = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    File.write("#{name}.png", data)
  end
end
