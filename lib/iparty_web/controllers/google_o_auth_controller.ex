defmodule IpartyWeb.GoogleOAuthController do
  use IpartyWeb, :controller

  alias Iparty.Base.Google
  alias Iparty.Accounts

  def google_request(conn, _params) do
    redirect(conn, external: Google.generate_uri())
  end

  def google_callback(conn, %{"code" => code} = _params) do
    token = Google.get_token(code)
    token_info = Google.get_token_info(token.id_token)
    expire = Google.forge_expire(token.expires_in)
    user = conn.assigns.current_user

    params = %{
      access_token: token.access_token,
      refresh_token: token.refresh_token,
      json_data: Poison.encode!(token_info),
      expire_at: expire,
      user_id: user.id
    }

    case Accounts.create_google_o_auth(params) do
      {:ok, _token} ->
        conn
        |> put_flash(:info, "Google Account connected. Enjoy the app!")
        |> redirect(to: Routes.page_path(conn, :iparty))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Google failed to connect!")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
