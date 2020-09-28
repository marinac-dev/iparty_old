defmodule Iparty.Base.Google do
  @auth_url "https://accounts.google.com/o/oauth2/v2/auth?"
  @token_url "https://oauth2.googleapis.com/token"
  @token_info "https://oauth2.googleapis.com/tokeninfo"
  @revoke_url "https://accounts.google.com/o/oauth2/revoke"

  alias Iparty.Accounts

  def generate_uri() do
    @auth_url <>
      "access_type=offline&" <>
      "scope=#{config().scope}&" <>
      "client_id=#{config().client_id}&" <>
      "redirect_uri=#{config().callback_uri}&" <>
      "include_granted_scopes=true&" <>
      "prompt=consent&" <>
      "response_type=code"
  end

  def generate_connect_uri() do
    @auth_url <>
      "access_type=offline&" <>
      "scope=#{config().scope}&" <>
      "client_id=#{config().client_id}&" <>
      "redirect_uri=#{config().connect_uri}&" <>
      "include_granted_scopes=true&" <>
      "response_type=code"
  end

  def get_token(code) do
    body =
      Jason.encode!(%{
        code: code,
        client_id: config().client_id,
        redirect_uri: config().callback_uri,
        client_secret: config().client_secret,
        grant_type: "authorization_code"
      })

    resp = HTTPoison.post!(@token_url, body)
    Jason.decode!(resp.body, keys: :atoms)
  end

  def get_refresh_token(refresh_token) do
    body =
      Jason.encode!(%{
        refresh_token: refresh_token,
        client_id: config().client_id,
        redirect_uri: config().callback_uri,
        client_secret: config().client_secret,
        grant_type: "refresh_token"
      })

    resp = HTTPoison.post!(@token_url, body)
    Jason.decode!(resp.body, keys: :atoms)
  end

  def get_token_info(id_token) do
    url = @token_info <> "?id_token=#{id_token}"
    body = HTTPoison.get!(url).body
    Jason.decode!(body, keys: :atoms)
  end

  # Refresh access token
  def refresh_token(token) do
    request_body =
      Jason.encode!(%{
        refresh_token: token.refresh_token,
        client_id: config().client_id,
        redirect_uri: config().callback_uri,
        client_secret: config().client_secret,
        grant_type: "refresh_token"
      })

    %{body: response_body} = HTTPoison.post!(@token_url, request_body)
    resp = response_body |> Jason.decode!()

    params = %{
      access_token: resp["access_token"],
      expire_at: forge_expire(resp["expires_in"])
    }

    Accounts.update_google_o_auth(token, params)
  end

  # Revoke acces tokeb
  def revoke_token(google) do
    token = URI.encode_www_form(google.refresh_token)
    url = @revoke_url <> "?token=#{token}"
    headers = [{"Content-type", "application/x-www-form-urlencoded"}]

    case HTTPoison.get(url, headers) do
      {:ok, resp} -> handle_revoke(google, resp)
      {:error, _} -> {:error, :request_failed}
    end
  end

  defp handle_revoke(google, %{status_code: 200}),
    do: Iparty.Accounts.delete_google_o_auth(google)

  defp handle_revoke(_, %{status_code: 400}), do: {:error, :already_revoked}

  defp config(), do: Application.get_env(:iparty, :google_oauth2)

  # Token expire_at calc
  def forge_expire(expires_in) do
    DateTime.utc_now()
    |> DateTime.to_unix(:second)
    |> forge_time(expires_in)
    |> DateTime.to_naive()
  end

  defp forge_time(now, expires_in) do
    {:ok, time} = DateTime.from_unix(now + expires_in)
    time
  end
end
